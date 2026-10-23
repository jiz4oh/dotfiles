{{/* chezmoi:modify-template */}}
{{- $start := "<!-- chezmoi:global-agents:start -->" -}}
{{- $end := "<!-- chezmoi:global-agents:end -->" -}}
{{- $block := includeTemplate "agents-global.md" . -}}
{{- $block = regexReplaceAll "[\r\n]+$" $block "" -}}
{{- /* opencode only: the Chinese-output rule lives in the primary agent prompts (build/orchestrator), not in shared AGENTS.md */ -}}
{{- $block = regexReplaceAll "(?m)^- [^\n]*\\$deliver-in-chinese[^\n]*\n" $block "" -}}
{{- $current := .chezmoi.stdin -}}

{{- if and (contains $start $current) (contains $end $current) -}}
  {{- $parts := splitn $start 2 $current -}}
  {{- $before := $parts._0 -}}
  {{- $rest := $parts._1 -}}
  {{- $parts2 := splitn $end 2 $rest -}}
  {{- $after := regexReplaceAll "^[\r\n]+" $parts2._1 "" -}}
  {{- if $after -}}
    {{- printf "%s%s\n\n%s" $before $block $after -}}
  {{- else -}}
    {{- printf "%s%s\n" $before $block -}}
  {{- end -}}
{{- else if or (contains $start $current) (contains $end $current) -}}
  {{- fail "AGENTS.md contains an incomplete chezmoi managed block" -}}
{{- else -}}
  {{- $clean := regexReplaceAll "[\r\n]+$" $current "" -}}
  {{- if $clean -}}
    {{- printf "%s\n\n%s\n" $clean $block -}}
  {{- else -}}
    {{- printf "%s\n" $block -}}
  {{- end -}}
{{- end -}}
