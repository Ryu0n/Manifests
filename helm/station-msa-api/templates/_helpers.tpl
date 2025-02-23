{{/*
Expand the name of the chart.
*/}}
{{- define "station-msa-api.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "station-msa-api.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "station-msa-api.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "station-msa-api.labels" -}}
helm.sh/chart: {{ include "station-msa-api.chart" . }}
{{ include "station-msa-api.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "station-msa-api.selectorLabels" -}}
app.kubernetes.io/name: {{ include "station-msa-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "station-msa-api.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "station-msa-api.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the path string to refer to the image file
*/}}
{{- define "readImageFile" -}}
{{- $file := printf "images/%s" .deploymentName -}}
{{- .Files.Get $file | quote -}}
{{- end -}}


{{/*
Prometheus annotations
*/}}
{{- define "station-msa-api.prometheus.annotations" -}}
{{- with .Values.prometheus -}}
prometheus.io/scrape: {{ .scrape | quote }}
prometheus.io/port: {{ .port | quote }}
prometheus.io/path: {{ .path | quote }}
{{- end -}}
{{- end -}}
