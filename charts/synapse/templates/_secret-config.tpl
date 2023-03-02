{{/* Define the configs */}}
{{- define "synapse.config" -}}
---
apiVersion: v1
kind: Secret
metadata:
  name: synapse-config
  {{/* name: {{ include "matrix.fullname" . }}-synapse-config */ -}}
  labels:
    {{- include "common.labels" . | nindent 4 }}
  annotations:
    rollme: {{ randAlphaNum 5 | quote }}
stringData:
  homeserver.yaml: |
    {{- include "homeserver.yaml" . | nindent 4 }}

  {{ .Values.appConfig.homeserver.server_name }}.log.config: |
    {{- include "log.config" . | nindent 4 }}

  {{ if .Values.appConfig.signingKey }}
  {{- .Values.appConfig.homeserver.server_name }}.signing.key: |
    {{- .Values.appConfig.signingKey | nindent 4 }}
  {{ end }}
    
{{ end }}
