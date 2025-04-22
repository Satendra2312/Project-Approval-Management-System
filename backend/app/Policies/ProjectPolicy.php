<?php

namespace App\Policies;

use App\Models\Project;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class ProjectPolicy
{
    use HandlesAuthorization;

    public function approve(User $user, Project $project)
    {
        return $user->role === 'admin';
    }

    public function reject(User $user, Project $project)
    {
        return $user->role === 'admin';
    }

    // Optional: Define policies for viewing, editing, deleting projects if needed
    public function view(User $user, Project $project)
    {
        return $user->role === 'admin' || $project->user_id === $user->id;
    }
}
