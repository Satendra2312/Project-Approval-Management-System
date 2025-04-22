<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProjectResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description,
            'filePath' => $this->file_path ? asset('storage/' . $this->file_path) : null,
            'status' => $this->status,
            'submittedBy' => [
                'id' => $this->user->id,
                'name' => $this->user->name,
                'email' => $this->user->email,
            ],
            'submissionDate' => $this->created_at->format('Y-m-d H:i:s'),
            'lastUpdated' => $this->updated_at->format('Y-m-d H:i:s'),
            'approvals' => $this->whenLoaded('approvals', function () {
                return $this->approvals->map(function ($approval) {
                    return [
                        'status' => $approval->status,
                        'reason' => $approval->reason,
                        'approvedBy' => $approval->admin ? $approval->admin->name : null,
                        'approvedAt' => $approval->created_at->format('Y-m-d H:i:s'),
                    ];
                });
            }),
        ];
    }
}
