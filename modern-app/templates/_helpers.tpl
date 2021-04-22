{{/*
Expand the name of the chart.
*/}}
{{- define "modern-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "modern-app.fullname" -}}
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
{{- define "modern-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "modern-app.labels" -}}
helm.sh/chart: {{ include "modern-app.chart" . }}
{{ include "modern-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "modern-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "modern-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "modern-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "modern-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{- define "imagePullSecret" }}
{{- if not (lookup "v1" "Secret" .Release.Namespace "acrKubLogin") }}
{{- with .Values.acrCredentials }}
{{- printf "{\"auths\":{\"%s.azurecr.io\":{\"username\":\"%s\",\"password\":\"%s\",\"auth\":\"%s\"}}}" (required "ACR Registry Name is Requied!" .registryName) (required "Service Principal ID is Requied!" .servicePrincipalId) (required "Service Principal Password is Requied!" .servicePrincipalPass) (printf "%s:%s" .servicePrincipalId .servicePrincipalPass | b64enc) | b64enc }}
{{- end }}
{{- end }}
{{- end }}