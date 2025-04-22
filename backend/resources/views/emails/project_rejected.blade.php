@component('mail::message')
# Your Project Has Been Rejected

Dear {{ $project->user->name }},

Your project "{{ $project->title }}" submitted on {{ $project->created_at->format('Y-m-d H:i:s') }} has been rejected.

**Reason:** {{ $reason }}

Please review the feedback and make necessary changes.

@component('mail::button', ['url' => url('/dashboard')])
View Dashboard
@endcomponent

Thanks,<br>
{{ config('app.name') }}
@endcomponent