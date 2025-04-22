@component('mail::message')
# New Project Submitted

Dear {{ $project->user->name }},

A new project "{{ $project->title }}" has been submitted on {{ $project->created_at->format('Y-m-d H:i:s') }}.

Thank you for your submission!

@component('mail::button', ['url' => url('/dashboard')])
View Dashboard
@endcomponent

Thanks,<br>
{{ config('app.name') }}
@endcomponent