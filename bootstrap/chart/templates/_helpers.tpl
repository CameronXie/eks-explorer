{{/*
Generate the complete Application manifest
Expects a dict with keys:
  - name: Application name (string)
  - app: Application configuration from values (dict)
  - root: Root context ($)
  - helm: Optional custom Helm configuration (dict)
*/}}
{{ define "bootstrap.application" }}
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {{ .name }}
  namespace: argocd
  {{- with .app.annotations }}
  annotations:
    {{ toYaml . | nindent 4 }}
  {{- end }}
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: {{ .app.project | default "cluster-addons" }}

  source:
    repoURL: {{ .root.Values.spec.source.repoURL }}
    targetRevision: {{ .root.Values.spec.source.targetRevision }}
    path: {{ .app.path }}
    {{- $helmConfig := .helm | default .app.helm }}
    {{- with $helmConfig }}
    helm:
      {{ toYaml . | nindent 6 }}
    {{- end }}

  destination:
    server: {{ .root.Values.spec.destination.server }}
    namespace: {{ .app.namespace }}

  {{- with .app.syncPolicy }}
  syncPolicy:
    {{- with .automated }}
    automated:
      {{ toYaml . | nindent 6 }}
    {{- end }}
    {{- with .syncOptions }}
    syncOptions:
      {{ toYaml . | nindent 6 }}
    {{- end }}
    {{- with .retry }}
    retry:
      {{ toYaml . | nindent 6 }}
    {{- end }}
  {{- end }}

  {{- with .app.ignoreDifferences }}
  ignoreDifferences:
    {{ toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
