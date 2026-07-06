{{- define "production-platform.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "production-platform.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "production-platform.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "production-platform.labels" -}}
app.kubernetes.io/name: {{ include "production-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "production-platform.selectorLabels" -}}
app.kubernetes.io/name: {{ include "production-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "production-platform.image" -}}
{{- $root := index . 0 -}}
{{- $svc := index . 1 -}}
{{- if $svc.repository -}}
{{- printf "%s:%s" $svc.repository $svc.tag -}}
{{- else -}}
{{- printf "%s/%s:%s" $root.Values.global.imageRegistry $svc.image $svc.tag -}}
{{- end -}}
{{- end -}}
