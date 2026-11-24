{{- /* opencode agent file. Data: (dict "name" <role> "roles" .roles). Reassembles model#effort. */ -}}
{{- $r := index .roles .name -}}
{{- $oc := $r.opencode -}}
---
description: {{ $r.description }}
mode: {{ $oc.mode }}
{{- with $r.model }}
model: {{ . }}{{ with $r.effort }}#{{ . }}{{ end }}
{{- end }}
{{- with $oc.permissions }}
permissions:
{{- range . }}
  - action: {{ .action }}
    resource: {{ .resource | quote }}
    effect: {{ .effect }}
{{- end }}
{{- end }}
---

{{ includeTemplate (printf "roles/%s.md" .name) . -}}
