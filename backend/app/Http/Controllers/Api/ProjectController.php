<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\ProjectSubmissionRequest;
use App\Http\Resources\ProjectResource;
use App\Jobs\SendProjectNotificationEmail;
use App\Models\AuditLog;
use App\Models\Project;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;

class ProjectController extends Controller
{
    use AuthorizesRequests;

    public function index(Request $request)
    {
        $query = Project::with('user');

        // Apply filters dynamically
        $filters = collect(['status', 'user_id'])
            ->filter(fn($key) => $request->has($key))
            ->mapWithKeys(fn($key) => [$key => $request->$key]);

        if ($filters->isNotEmpty()) {
            $query->where($filters->toArray());
        }

        // Sorting
        $sortColumn = $request->get('sort_by', 'created_at');
        $sortDirection = $request->get('sort_direction', 'desc');
        $query->orderBy($sortColumn, $sortDirection);

        // Paginate results
        $projects = $query->paginate(10);

        return response()->json([
            'success' => true,
            'message' => 'Projects retrieved successfully.',
            'totals' => [
                'all' => Project::count(),
                'pending' => Project::where('status', 'pending')->count(),
                'approved' => Project::where('status', 'approved')->count(),
                'rejected' => Project::where('status', 'rejected')->count(),
            ],
            'projects' => ProjectResource::collection($projects),
        ], 200);
    }

    public function store(ProjectSubmissionRequest $request)
    {
        try {
            $validated = $request->validated();

            $path = $request->hasFile('file')
                ? $request->file('file')->store('project_files', 'public')
                : null;

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

    public function approve(Project $project)
    {
        try {
            $this->authorize('approve', $project);

            $result = DB::select("CALL sp_update_project_status(?, ?, 'approved', NULL)", [$project->id, auth()->id()]);

            if ($result && $result[0]->status === 'success') {
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
            }

            return response()->json([
                'success' => false,
                'message' => 'Failed to approve project',
                'error' => $result[0]->message ?? 'Unknown error from stored procedure',
            ], 500);
        } catch (\Illuminate\Auth\Access\AuthorizationException $e) {
            return response()->json(['success' => false, 'message' => 'Unauthorized', 'error' => $e->getMessage()], 403);
        }
    }

    public function reject(Project $project, Request $request)
    {
        try {
            $this->authorize('reject', $project);

            if ($project->status === 'rejected') {
                return response()->json(['message' => 'Project is already rejected.'], 422);
            }

            $request->validate([
                'reason' => 'required|string',
            ]);

            DB::transaction(function () use ($project, $request) {
                $project->update(['status' => 'rejected']);

                $project->approvals()->create([
                    'admin_id' => auth()->id(),
                    'status' => 'rejected',
                    'reason' => $request->reason,
                ]);

                AuditLog::create([
                    'user_id' => auth()->id(),
                    'action' => 'project_rejected',
                    'auditable_id' => $project->id,
                    'auditable_type' => Project::class,
                ]);
            });

            SendProjectNotificationEmail::dispatch($project, 'rejected', $request->reason);

            return response()->json(['message' => 'Project rejected successfully']);
        } catch (\Illuminate\Auth\Access\AuthorizationException $e) {
            return response()->json(['message' => 'Unauthorized', 'error' => $e->getMessage()], 403);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Something went wrong.', 'error' => $e->getMessage()], 500);
        }
    }
}
