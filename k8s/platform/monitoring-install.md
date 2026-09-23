# Prometheus + Grafana + Loki (kube-prometheus-stack) - runbook Phase 3
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace observability \
  --set grafana.adminPassword=admin \
  --set grafana.ingress.enabled=true \
  --set grafana.ingress.hosts[0]=grafana.anoos.local \
  --set prometheus.prometheusSpec.retention=15d
helm install loki grafana/loki-stack --namespace observability \
  --set loki.persistence.enabled=true \
  --set loki.persistence.size=10Gi
