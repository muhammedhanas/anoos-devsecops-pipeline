# ArgoCD - installed via Helm (runbook Phase 3)
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  --set server.ingress.enabled=true \
  --set server.ingress.hostname=argocd.anoos.local \
  --set configs.params."server\.insecure"=true
