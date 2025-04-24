<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\ProjectSubmissionRequest;
use App\Http\Resources\ProjectResource;
use App\Jobs\SendProjectNotificationEmail;
use App\Models\AuditLog;
use App\Models\Project;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class ProjectController extends Controller
{
    use AuthorizesRequests;

    public function index(Request $request)
    {
        $query = Project::with('user');

        // Filtering
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }
        if ($request->has('user_id')) {
            $query->where('user_id', $request->user_id);
        }

        // Sorting
        if ($request->has('sort_by') && in_array($request->sort_by, ['created_at', 'title', 'status'])) {
            $sortDirection = $request->has('sort_direction') && in_array($request->sort_direction, ['asc', 'desc']) ? $request->sort_direction : 'desc';
            $query->orderBy($request->sort_by, $sortDirection);
        } else {
            $query->latest();
        }

        $projects = $query->paginate(10); // Get paginated projects

        // Calculate totals
        $totalProjects = Project::count();
        $totalPendingProjects = Project::where('status', 'pending')->count();
        $totalApprovalProjects = Project::where('status', 'approved')->count();
        $totalRejectProjects = Project::where('status', 'rejected')->count();

        $message = "Projects retrieved successfully.";
        $success = true;

        // Return the response with totals, projects data, message and success status.
        return response()->json([
            'success' => $success,
            'message' => $message,
            'total_projects' => $totalProjects,
            'total_pending_projects' => $totalPendingProjects,
            'total_approval_projects' => $totalApprovalProjects,
            'total_reject_projects' => $totalRejectProjects,
            'projects' => ProjectResource::collection($projects),
        ], 200); // 200 OK
    }


    public function store(ProjectSubmissionRequest $request)
    {
        try {
            $validated = $request->validated();

            $path = null;
            if ($request->hasFile('file')) {
                $path = $request->file('file')->store('project_files', 'public');
            }

            $project = Project::create([
                'user_id' => auth()->id(),
                'title' => $validated['title'],
                'description' => $validated['description'],
                'file_path' => $path,
                'status' => 'pending',
            ]);

            SendProjectNotificationEmail::dispatch($project, 'submitted');

            return response()->json([
                'message' => 'Project submitted successfully.',
                'data' => new ProjectResource($project),
            ], 201);
        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'message' => 'Validation failed.',
                'errors' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Something went wrong while submitting the project.',
                'error' => $e->getMessage(),
            ], 500);
        }
    }


    public function show(Project $project)
    {
        return new ProjectResource($project->load('user', 'approvals'));
    }

    public function approve(Project $project, Request $request)
    {
        try {
            $this->authorize('approve', $project);

            $result = DB::select("CALL sp_approve_project(?, ?)", [$project->id, auth()->id()]);

            if ($result && $result[0]->status === 'success') {

                // Send approval email
                SendProjectNotificationEmail::dispatch($project, 'approved');
                return response()->json([
                    'success' => true,
                    'message' => 'Project approved successfully',
                    'data' => [
                        'project_id' => $project->id,
                        'approved_by' => auth()->id(),
                        'approved_at' => now()->toDateTimeString(),
                    ],
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to approve project',
                    'error' => $result ? $result[0]->message ?? 'Unknown error from stored procedure' : 'Error executing stored procedure',
                ], 500);
            }
        } catch (AuthorizationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'This action is unauthorized.',
                'error' => $e->getMessage(),
            ], 403);
        }
    }

    public function reject(Project $project, Request $request)
    {
        try {
            $this->authorize('reject', $project);

            // Check if already rejected
            if ($project->status === 'rejected') {
                return response()->json(['message' => 'Project is already rejected.'], 422);
            }

            // Validate input
            $request->validate([
                'reason' => 'required|string',
            ]);

            // Update project status
            $project->update(['status' => 'rejected']);

            // Store rejection in approvals
            $project->approvals()->create([
                'admin_id' => auth()->id(),
                'status' => 'rejected',
                'reason' => $request->reason,
            ]);

            // Log rejection
            AuditLog::create([
                'user_id' => auth()->id(),
                'action' => 'project_rejected',
                'auditable_id' => $project->id,
                'auditable_type' => Project::class,
            ]);

            // Send email (queued)
            SendProjectNotificationEmail::dispatch($project, 'rejected', $request->reason);

            return response()->json(['message' => 'Project rejected successfully']);
        } catch (AuthorizationException $e) {
            return response()->json(['message' => $e->getMessage()], 403);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Something went wrong.', 'error' => $e->getMessage()], 500);
        }
    }
}
