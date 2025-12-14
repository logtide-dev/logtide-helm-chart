{{/*
Expand the name of the chart.
*/}}
{{- define "logward.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "logward.fullname" -}}
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
{{- define "logward.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "logward.labels" -}}
helm.sh/chart: {{ include "logward.chart" . }}
{{ include "logward.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "logward.selectorLabels" -}}
app.kubernetes.io/name: {{ include "logward.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Backend labels
*/}}
{{- define "logward.backend.labels" -}}
{{ include "logward.labels" . }}
app.kubernetes.io/component: backend
{{- end }}

{{- define "logward.backend.selectorLabels" -}}
{{ include "logward.selectorLabels" . }}
app.kubernetes.io/component: backend
{{- end }}

{{/*
Frontend labels
*/}}
{{- define "logward.frontend.labels" -}}
{{ include "logward.labels" . }}
app.kubernetes.io/component: frontend
{{- end }}

{{- define "logward.frontend.selectorLabels" -}}
{{ include "logward.selectorLabels" . }}
app.kubernetes.io/component: frontend
{{- end }}

{{/*
Worker labels
*/}}
{{- define "logward.worker.labels" -}}
{{ include "logward.labels" . }}
app.kubernetes.io/component: worker
{{- end }}

{{- define "logward.worker.selectorLabels" -}}
{{ include "logward.selectorLabels" . }}
app.kubernetes.io/component: worker
{{- end }}

{{/*
TimescaleDB labels
*/}}
{{- define "logward.timescaledb.labels" -}}
{{ include "logward.labels" . }}
app.kubernetes.io/component: timescaledb
{{- end }}

{{- define "logward.timescaledb.selectorLabels" -}}
{{ include "logward.selectorLabels" . }}
app.kubernetes.io/component: timescaledb
{{- end }}

{{/*
Redis labels
*/}}
{{- define "logward.redis.labels" -}}
{{ include "logward.labels" . }}
app.kubernetes.io/component: redis
{{- end }}

{{- define "logward.redis.selectorLabels" -}}
{{ include "logward.selectorLabels" . }}
app.kubernetes.io/component: redis
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "logward.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "logward.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Backend image
*/}}
{{- define "logward.backend.image" -}}
{{- $tag := default .Chart.AppVersion .Values.backend.image.tag }}
{{- printf "%s:%s" .Values.backend.image.repository $tag }}
{{- end }}

{{/*
Frontend image
*/}}
{{- define "logward.frontend.image" -}}
{{- $tag := default .Chart.AppVersion .Values.frontend.image.tag }}
{{- printf "%s:%s" .Values.frontend.image.repository $tag }}
{{- end }}

{{/*
Worker image (uses backend image)
*/}}
{{- define "logward.worker.image" -}}
{{- $tag := default .Chart.AppVersion .Values.worker.image.tag }}
{{- printf "%s:%s" .Values.worker.image.repository $tag }}
{{- end }}

{{/*
Database host
*/}}
{{- define "logward.database.host" -}}
{{- if .Values.timescaledb.enabled }}
{{- printf "%s-timescaledb" (include "logward.fullname" .) }}
{{- else }}
{{- .Values.externalDatabase.host }}
{{- end }}
{{- end }}

{{/*
Database port
*/}}
{{- define "logward.database.port" -}}
{{- if .Values.timescaledb.enabled }}
{{- 5432 }}
{{- else }}
{{- .Values.externalDatabase.port }}
{{- end }}
{{- end }}

{{/*
Database name
*/}}
{{- define "logward.database.name" -}}
{{- if .Values.timescaledb.enabled }}
{{- .Values.timescaledb.auth.database }}
{{- else }}
{{- .Values.externalDatabase.database }}
{{- end }}
{{- end }}

{{/*
Database user
*/}}
{{- define "logward.database.user" -}}
{{- if .Values.timescaledb.enabled }}
{{- .Values.timescaledb.auth.username }}
{{- else }}
{{- .Values.externalDatabase.username }}
{{- end }}
{{- end }}

{{/*
Database secret name
*/}}
{{- define "logward.database.secretName" -}}
{{- if .Values.timescaledb.enabled }}
{{- printf "%s-timescaledb" (include "logward.fullname" .) }}
{{- else if .Values.externalDatabase.existingSecret }}
{{- .Values.externalDatabase.existingSecret }}
{{- else }}
{{- printf "%s-external-db" (include "logward.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Redis host
*/}}
{{- define "logward.redis.host" -}}
{{- if .Values.redis.enabled }}
{{- printf "%s-redis" (include "logward.fullname" .) }}
{{- else }}
{{- .Values.externalRedis.host }}
{{- end }}
{{- end }}

{{/*
Redis port
*/}}
{{- define "logward.redis.port" -}}
{{- if .Values.redis.enabled }}
{{- 6379 }}
{{- else }}
{{- .Values.externalRedis.port }}
{{- end }}
{{- end }}

{{/*
Redis secret name
*/}}
{{- define "logward.redis.secretName" -}}
{{- if .Values.redis.enabled }}
{{- printf "%s-redis" (include "logward.fullname" .) }}
{{- else if .Values.externalRedis.existingSecret }}
{{- .Values.externalRedis.existingSecret }}
{{- else }}
{{- printf "%s-external-redis" (include "logward.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Secrets name
*/}}
{{- define "logward.secretsName" -}}
{{- printf "%s-secrets" (include "logward.fullname" .) }}
{{- end }}

{{/*
ConfigMap name
*/}}
{{- define "logward.configMapName" -}}
{{- printf "%s-config" (include "logward.fullname" .) }}
{{- end }}
