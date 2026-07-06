# Monitoring

Install kube-prometheus-stack:

```bash
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

Apply platform alerts:

```bash
kubectl apply -f monitoring/prometheus/rules/platform-alerts.yaml -n monitoring
```

Import `monitoring/grafana/dashboards/application-dashboard.json` into Grafana.

Alert coverage:

- CPU usage above 80%
- Memory usage above 85%
- Pod restart spikes
- Node exporter target down
- PVC usage above 85%

Install Loki and Promtail:

```bash
helm upgrade --install loki grafana/loki -n logging --create-namespace -f logging/loki/values.yaml
helm upgrade --install promtail grafana/promtail -n logging -f logging/promtail/values.yaml
```
