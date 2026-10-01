{{/* chezmoi:modify-template */}}
{{- $start := "<!-- chezmoi:global-agents:start -->" -}}
{{- $end := "<!-- chezmoi:global-agents:end -->" -}}
{{- $block := includeTemplate "agents-global.md" . -}}
{{- $current := .chezmoi.stdin -}}

{{- if and (contains $start $current) (contains $end $current) -}}
  {{- $parts := splitn $start 2 $current -}}
  {{- $before := $parts._0 -}}
  {{- $rest := $parts._1 -}}
  {{- $parts2 := splitn $end 2 $rest -}}
  {{- $after := $parts2._1 -}}
{{ $before }}{{ $block }}{{ $after }}
{{- else if or (contains $start $current) (contains $end $current) -}}
  {{- fail "AGENTS.md contains an incomplete chezmoi managed block" -}}
{{- else -}}
{{ $current }}
{{- if $current }}

{{- end -}}
{{ $block }}
{{- end -}}
