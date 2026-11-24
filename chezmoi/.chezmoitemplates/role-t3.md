{{- /* T3 role file. Data: (dict "name" <role> "roles" .roles). model/effort stay split. */ -}}
{{- $r := index .roles .name -}}
---
name: {{ .name }}
description: {{ $r.description }}
t3_role: {{ $r.t3_role }}
{{- with $r.model }}
model: {{ . }}
{{- end }}
{{- with $r.effort }}
effort: {{ . }}
{{- end }}
readonly: {{ $r.readonly }}
---

{{ includeTemplate (printf "roles/%s.md" .name) . -}}
