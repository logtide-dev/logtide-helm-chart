{{/*
Expand the name of the chart.
*/}}
{{- define "logtide.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "logtide.fullname" -}}
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
{{- define "logtide.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "logtide.labels" -}}
helm.sh/chart: {{ include "logtide.chart" . }}
{{ include "logtide.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "logtide.selectorLabels" -}}
app.kubernetes.io/name: {{ include "logtide.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Backend labels
*/}}
{{- define "logtide.backend.labels" -}}
{{ include "logtide.labels" . }}
app.kubernetes.io/component: backend
{{- end }}

{{- define "logtide.backend.selectorLabels" -}}
{{ include "logtide.selectorLabels" . }}
app.kubernetes.io/component: backend
{{- end }}

{{/*
Frontend labels
*/}}
{{- define "logtide.frontend.labels" -}}
{{ include "logtide.labels" . }}
app.kubernetes.io/component: frontend
{{- end }}

{{- define "logtide.frontend.selectorLabels" -}}
{{ include "logtide.selectorLabels" . }}
app.kubernetes.io/component: frontend
{{- end }}

{{/*
Worker labels
*/}}
{{- define "logtide.worker.labels" -}}
{{ include "logtide.labels" . }}
app.kubernetes.io/component: worker
{{- end }}

{{- define "logtide.worker.selectorLabels" -}}
{{ include "logtide.selectorLabels" . }}
app.kubernetes.io/component: worker
{{- end }}

{{/*
TimescaleDB labels
*/}}
{{- define "logtide.timescaledb.labels" -}}
{{ include "logtide.labels" . }}
app.kubernetes.io/component: timescaledb
{{- end }}

{{- define "logtide.timescaledb.selectorLabels" -}}
{{ include "logtide.selectorLabels" . }}
app.kubernetes.io/component: timescaledb
{{- end }}

{{/*
Redis labels
*/}}
{{- define "logtide.redis.labels" -}}
{{ include "logtide.labels" . }}
app.kubernetes.io/component: redis
{{- end }}

{{- define "logtide.redis.selectorLabels" -}}
{{ include "logtide.selectorLabels" . }}
app.kubernetes.io/component: redis
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "logtide.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "logtide.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Backend image
*/}}
{{- define "logtide.backend.image" -}}
{{- $tag := default .Chart.AppVersion .Values.backend.image.tag }}
{{- printf "%s:%s" .Values.backend.image.repository $tag }}
{{- end }}

{{/*
Frontend image
*/}}
{{- define "logtide.frontend.image" -}}
{{- $tag := default .Chart.AppVersion .Values.frontend.image.tag }}
{{- printf "%s:%s" .Values.frontend.image.repository $tag }}
{{- end }}

{{/*
Worker image (uses backend image)
*/}}
{{- define "logtide.worker.image" -}}
{{- $tag := default .Chart.AppVersion .Values.worker.image.tag }}
{{- printf "%s:%s" .Values.worker.image.repository $tag }}
{{- end }}

{{/*
Database host
*/}}
{{- define "logtide.database.host" -}}
{{- if .Values.timescaledb.enabled }}
{{- printf "%s-timescaledb" (include "logtide.fullname" .) }}
{{- else }}
{{- .Values.externalDatabase.host }}
{{- end }}
{{- end }}

{{/*
Database port
*/}}
{{- define "logtide.database.port" -}}
{{- if .Values.timescaledb.enabled }}
{{- 5432 }}
{{- else }}
{{- .Values.externalDatabase.port }}
{{- end }}
{{- end }}

{{/*
Database name
*/}}
{{- define "logtide.database.name" -}}
{{- if .Values.timescaledb.enabled }}
{{- .Values.timescaledb.auth.database }}
{{- else }}
{{- .Values.externalDatabase.database }}
{{- end }}
{{- end }}

{{/*
Database user
*/}}
{{- define "logtide.database.user" -}}
{{- if .Values.timescaledb.enabled }}
{{- .Values.timescaledb.auth.username }}
{{- else }}
{{- .Values.externalDatabase.username }}
{{- end }}
{{- end }}

{{/*
Database secret name
*/}}
{{- define "logtide.database.secretName" -}}
{{- if .Values.timescaledb.enabled }}
{{- printf "%s-timescaledb" (include "logtide.fullname" .) }}
{{- else if .Values.externalDatabase.existingSecret }}
{{- .Values.externalDatabase.existingSecret }}
{{- else }}
{{- printf "%s-external-db" (include "logtide.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Redis host
*/}}
{{- define "logtide.redis.host" -}}
{{- if .Values.redis.enabled }}
{{- printf "%s-redis" (include "logtide.fullname" .) }}
{{- else }}
{{- .Values.externalRedis.host }}
{{- end }}
{{- end }}

{{/*
Redis port
*/}}
{{- define "logtide.redis.port" -}}
{{- if .Values.redis.enabled }}
{{- 6379 }}
{{- else }}
{{- .Values.externalRedis.port }}
{{- end }}
{{- end }}

{{/*
Redis secret name
*/}}
{{- define "logtide.redis.secretName" -}}
{{- if .Values.redis.enabled }}
{{- printf "%s-redis" (include "logtide.fullname" .) }}
{{- else if .Values.externalRedis.existingSecret }}
{{- .Values.externalRedis.existingSecret }}
{{- else }}
{{- printf "%s-external-redis" (include "logtide.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Secrets name
*/}}
{{- define "logtide.secretsName" -}}
{{- printf "%s-secrets" (include "logtide.fullname" .) }}
{{- end }}

{{/*
ConfigMap name
*/}}
{{- define "logtide.configMapName" -}}
{{- printf "%s-config" (include "logtide.fullname" .) }}
{{- end }}
