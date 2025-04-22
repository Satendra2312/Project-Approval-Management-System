@component('mail::message')
# Your Project Has Been Approved!

Dear {{ $project->user->name }},

Your project "{{ $project->title }}" has been approved on {{ now()->format('Y-m-d H:i:s') }}.

Congratulations!

@component('mail::button', ['url' => url('/dashboard')])
View Dashboard
@endcomponent

Thanks,<br>
{{ config('app.name') }}
@endcomponent