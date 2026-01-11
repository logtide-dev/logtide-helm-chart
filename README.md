<p align="center">
  <img src="https://raw.githubusercontent.com/logtide-dev/logtide/main/docs/images/logo.png" alt="LogTide Logo" width="400">
</p>

<h1 align="center">LogTide Helm Chart</h1>

<p align="center">
  <a href="https://artifacthub.io/packages/helm/logtide/logtide"><img src="https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/logtide" alt="Artifact Hub"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License"></a>
  <a href="https://github.com/logtide-dev/logtide-helm-chart/releases"><img src="https://img.shields.io/github/v/release/logtide-dev/logtide-helm-chart" alt="Release"></a>
</p>

<p align="center">
  Official Helm chart for deploying <a href="https://logtide.dev">LogTide</a> on Kubernetes.
</p>

---

## Overview

LogTide is an open-source log management and SIEM platform featuring:

- High-performance log ingestion (10,000+ logs/sec)
- Real-time log streaming via SSE
- Advanced search and filtering
- Sigma-based security detection
- SIEM dashboard with incident management
- MITRE ATT&CK mapping

## Prerequisites

- Kubernetes 1.25+
- Helm 3.10+
- PV provisioner support (for persistence)

## Installation

### Add the Helm repository

```bash
helm repo add logtide https://logtide-dev.github.io/logtide-helm-chart
helm repo update
```

### Install the chart

```bash
# Create namespace
kubectl create namespace logtide

# Install with default values
helm install logtide logtide/logtide \
  --namespace logtide \
  --set timescaledb.auth.password=<your-db-password> \
  --set timescaledb.auth.postgresPassword=<your-postgres-password> \
  --set redis.auth.password=<your-redis-password>
```

### Install from source

```bash
git clone https://github.com/logtide-dev/logtide-helm-chart.git
cd logtide-helm-chart

helm install logtide ./charts/logtide \
  --namespace logtide \
  --create-namespace \
  --set timescaledb.auth.password=<your-db-password> \
  --set timescaledb.auth.postgresPassword=<your-postgres-password> \
  --set redis.auth.password=<your-redis-password>
```

## Configuration

See [values.yaml](charts/logtide/values.yaml) for the full list of configurable parameters.

### Key Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `backend.replicaCount` | Number of backend replicas | `2` |
| `backend.autoscaling.enabled` | Enable HPA for backend | `true` |
| `frontend.replicaCount` | Number of frontend replicas | `2` |
| `worker.replicaCount` | Number of worker replicas | `2` |
| `timescaledb.enabled` | Deploy embedded TimescaleDB | `true` |
| `timescaledb.persistence.size` | Database storage size | `50Gi` |
| `redis.enabled` | Deploy embedded Redis | `true` |
| `ingress.enabled` | Enable Ingress | `false` |

### Using External Database

```yaml
timescaledb:
  enabled: false

externalDatabase:
  host: my-timescaledb.example.com
  port: 5432
  database: logtide
  username: logtide
  password: secret
  # Or use existing secret:
  # existingSecret: my-db-secret
  # existingSecretPasswordKey: password
```

### Using External Redis

```yaml
redis:
  enabled: false

externalRedis:
  host: my-redis.example.com
  port: 6379
  password: secret
```

### Enable Ingress

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: logtide.example.com
      paths:
        - path: /
          pathType: Prefix
          service: frontend
        - path: /api
          pathType: Prefix
          service: backend
        - path: /v1
          pathType: Prefix
          service: backend
  tls:
    - secretName: logtide-tls
      hosts:
        - logtide.example.com
```

### Enable Prometheus Monitoring

```yaml
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
```

## Cloud-Specific Examples

### AWS EKS

```yaml
global:
  storageClass: gp3

ingress:
  enabled: true
  className: alb
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:...

timescaledb:
  persistence:
    storageClass: gp3

redis:
  persistence:
    storageClass: gp3
```

### GCP GKE

```yaml
global:
  storageClass: standard-rwo

ingress:
  enabled: true
  className: gce
  annotations:
    kubernetes.io/ingress.global-static-ip-name: logtide-ip

timescaledb:
  persistence:
    storageClass: standard-rwo
```

### Azure AKS

```yaml
global:
  storageClass: managed-premium

ingress:
  enabled: true
  className: azure-application-gateway
  annotations:
    appgw.ingress.kubernetes.io/ssl-redirect: "true"

timescaledb:
  persistence:
    storageClass: managed-premium
```

## Upgrading

```bash
helm repo update
helm upgrade logtide logtide/logtide --namespace logtide
```

### From 0.x to 1.x

No breaking changes. Standard upgrade process applies.

## Uninstalling

```bash
helm uninstall logtide --namespace logtide

# If you want to delete PVCs as well:
kubectl delete pvc -l app.kubernetes.io/instance=logtide -n logtide
```

## Troubleshooting

### Pods not starting

Check pod events:
```bash
kubectl describe pod -l app.kubernetes.io/instance=logtide -n logtide
```

Check logs:
```bash
kubectl logs -l app.kubernetes.io/instance=logtide -n logtide --all-containers
```

### Database connection issues

Verify database secret:
```bash
kubectl get secret logtide-timescaledb -n logtide -o jsonpath="{.data.password}" | base64 -d
```

Test connection:
```bash
kubectl run pg-test --rm -it --image=postgres:15 --restart=Never -- \
  psql -h logtide-timescaledb -U logtide -d logtide
```

### Ingress not working

Check Ingress status:
```bash
kubectl describe ingress logtide -n logtide
```

Verify services:
```bash
kubectl get svc -n logtide
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `helm lint charts/logtide`
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details.

## Links

- [LogTide Website](https://logtide.dev)
- [Documentation](https://docs.logtide.dev)
- [Main Repository](https://github.com/logtide-dev/logtide)
- [Issues](https://github.com/logtide-dev/logtide-helm-chart/issues)
