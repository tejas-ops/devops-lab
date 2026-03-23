{{/*
_helpers.tpl — reusable template snippets
These are called with {{ include "devops-lab.xxx" . }} in other templates
*/}}

{{/* Full name of the release */}}
{{- define "devops-lab.fullname" -}}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Common labels applied to every resource */}}
{{- define "devops-lab.labels" -}}
app: {{ include "devops-lab.fullname" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Selector labels used by Deployment and Service to find pods */}}
{{- define "devops-lab.selectorLabels" -}}
app: {{ include "devops-lab.fullname" . }}
{{- end }}
