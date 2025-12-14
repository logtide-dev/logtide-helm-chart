<p align="center">
  <img src="https://raw.githubusercontent.com/logward-dev/logward/main/docs/images/logo.png" alt="LogWard Logo" width="400">
</p>

<h1 align="center">LogWard Helm Chart</h1>

<p align="center">
  <a href="https://artifacthub.io/packages/helm/logward/logward"><img src="https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/logward" alt="Artifact Hub"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License"></a>
  <a href="https://github.com/logward-dev/logward-helm-chart/releases"><img src="https://img.shields.io/github/v/release/logward-dev/logward-helm-chart" alt="Release"></a>
</p>

<p align="center">
  Official Helm chart for deploying <a href="https://logward.dev">LogWard</a> on Kubernetes.
</p>

---

## Overview

LogWard is an open-source log management and SIEM platform featuring:

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
helm repo add logward https://logward-dev.github.io/logward-helm-chart
helm repo update
```

### Install the chart

```bash
# Create namespace
kubectl create namespace logward

# Install with default values
helm install logward logward/logward \
  --namespace logward \
  --set timescaledb.auth.password=<your-db-password> \
  --set timescaledb.auth.postgresPassword=<your-postgres-password> \
  --set redis.auth.password=<your-redis-password>
```

### Install from source

```bash
git clone https://github.com/logward-dev/logward-helm-chart.git
cd logward-helm-chart

helm install logward ./charts/logward \
  --namespace logward \
  --create-namespace \
  --set timescaledb.auth.password=<your-db-password> \
  --set timescaledb.auth.postgresPassword=<your-postgres-password> \
  --set redis.auth.password=<your-redis-password>
```

## Configuration

See [values.yaml](charts/logward/values.yaml) for the full list of configurable parameters.

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
  database: logward
  username: logward
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
    - host: logward.example.com
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
    - secretName: logward-tls
      hosts:
        - logward.example.com
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
    kubernetes.io/ingress.global-static-ip-name: logward-ip

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
helm upgrade logward logward/logward --namespace logward
```

### From 0.x to 1.x

No breaking changes. Standard upgrade process applies.

## Uninstalling

```bash
helm uninstall logward --namespace logward

# If you want to delete PVCs as well:
kubectl delete pvc -l app.kubernetes.io/instance=logward -n logward
```

## Troubleshooting

### Pods not starting

Check pod events:
```bash
kubectl describe pod -l app.kubernetes.io/instance=logward -n logward
```

Check logs:
```bash
kubectl logs -l app.kubernetes.io/instance=logward -n logward --all-containers
```

### Database connection issues

Verify database secret:
```bash
kubectl get secret logward-timescaledb -n logward -o jsonpath="{.data.password}" | base64 -d
```

Test connection:
```bash
kubectl run pg-test --rm -it --image=postgres:15 --restart=Never -- \
  psql -h logward-timescaledb -U logward -d logward
```

### Ingress not working

Check Ingress status:
```bash
kubectl describe ingress logward -n logward
```

Verify services:
```bash
kubectl get svc -n logward
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `helm lint charts/logward`
5. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details.

## Links

- [LogWard Website](https://logward.dev)
- [Documentation](https://docs.logward.dev)
- [Main Repository](https://github.com/logward-dev/logward)
- [Issues](https://github.com/logward-dev/logward-helm-chart/issues)
