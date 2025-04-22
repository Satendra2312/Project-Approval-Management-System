<?php

namespace App\Jobs;

use App\Mail\ProjectApprovedMail;
use App\Mail\ProjectRejectedMail;
use App\Mail\ProjectSubmittedMail;
use App\Models\Project;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Mail;

class SendProjectNotificationEmail implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $project;
    public $type;
    public $reason;

    /**
     * Create a new job instance.
     */
    public function __construct(Project $project, string $type, string $reason = null)
    {
        $this->project = $project;
        $this->type = $type;
        $this->reason = $reason;
    }

    /**
     * Execute the job.
     */
    public function handle(): void
    {
        switch ($this->type) {
            case 'submitted':
                Mail::to($this->project->user->email)->send(new ProjectSubmittedMail($this->project));
                break;
            case 'approved':
                Mail::to($this->project->user->email)->send(new ProjectApprovedMail($this->project));
                break;
            case 'rejected':
                Mail::to($this->project->user->email)->send(new ProjectRejectedMail($this->project, $this->reason));
                break;
        }
    }
}
