<p align="center">
  <img src="https://raw.githubusercontent.com/logtide-dev/logtide/main/docs/images/logo.png" alt="LogTide Logo" width="400">
</p>

# LogTide Helm Chart

A Helm chart for deploying LogTide on Kubernetes.

## Introduction

This chart bootstraps a LogTide deployment on a Kubernetes cluster using the Helm package manager.

## Prerequisites

- Kubernetes 1.25+
- Helm 3.10+
- PV provisioner support in the underlying infrastructure

## Installing the Chart

```bash
helm install logtide ./logtide \
  --namespace logtide \
  --create-namespace \
  --set timescaledb.auth.password=<password> \
  --set timescaledb.auth.postgresPassword=<password> \
  --set redis.auth.password=<password>
```

## Configuration

The following table lists the configurable parameters and their default values.

### Global

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.imagePullSecrets` | Image pull secrets | `[]` |
| `global.storageClass` | Storage class for PVCs | `""` |

### Backend

| Parameter | Description | Default |
|-----------|-------------|---------|
| `backend.enabled` | Enable backend | `true` |
| `backend.replicaCount` | Number of replicas | `2` |
| `backend.image.repository` | Image repository | `ghcr.io/logtide-dev/logtide-backend` |
| `backend.image.tag` | Image tag | `""` (uses appVersion) |
| `backend.resources.requests.cpu` | CPU request | `100m` |
| `backend.resources.requests.memory` | Memory request | `256Mi` |
| `backend.resources.limits.cpu` | CPU limit | `1000m` |
| `backend.resources.limits.memory` | Memory limit | `1Gi` |
| `backend.autoscaling.enabled` | Enable HPA | `true` |
| `backend.autoscaling.minReplicas` | Min replicas | `2` |
| `backend.autoscaling.maxReplicas` | Max replicas | `10` |

### Frontend

| Parameter | Description | Default |
|-----------|-------------|---------|
| `frontend.enabled` | Enable frontend | `true` |
| `frontend.replicaCount` | Number of replicas | `2` |
| `frontend.image.repository` | Image repository | `ghcr.io/logtide-dev/logtide-frontend` |
| `frontend.resources.requests.cpu` | CPU request | `50m` |
| `frontend.resources.requests.memory` | Memory request | `128Mi` |

### Worker

| Parameter | Description | Default |
|-----------|-------------|---------|
| `worker.enabled` | Enable worker | `true` |
| `worker.replicaCount` | Number of replicas | `2` |
| `worker.autoscaling.enabled` | Enable HPA | `true` |
| `worker.autoscaling.maxReplicas` | Max replicas | `8` |

### TimescaleDB

| Parameter | Description | Default |
|-----------|-------------|---------|
| `timescaledb.enabled` | Deploy TimescaleDB | `true` |
| `timescaledb.image.repository` | Image repository | `timescale/timescaledb` |
| `timescaledb.image.tag` | Image tag | `latest-pg15` |
| `timescaledb.auth.database` | Database name | `logtide` |
| `timescaledb.auth.username` | Database user | `logtide` |
| `timescaledb.auth.password` | Database password | `""` (required) |
| `timescaledb.persistence.enabled` | Enable persistence | `true` |
| `timescaledb.persistence.size` | PVC size | `50Gi` |

### Redis

| Parameter | Description | Default |
|-----------|-------------|---------|
| `redis.enabled` | Deploy Redis | `true` |
| `redis.image.repository` | Image repository | `redis` |
| `redis.image.tag` | Image tag | `7-alpine` |
| `redis.auth.enabled` | Enable authentication | `true` |
| `redis.auth.password` | Redis password | `""` (required) |
| `redis.persistence.enabled` | Enable persistence | `true` |
| `redis.persistence.size` | PVC size | `10Gi` |

### Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable Ingress | `false` |
| `ingress.className` | Ingress class | `nginx` |
| `ingress.hosts` | Ingress hosts | See values.yaml |
| `ingress.tls` | TLS configuration | `[]` |

### Application Config

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.nodeEnv` | Node environment | `production` |
| `config.logLevel` | Log level | `info` |
| `config.jwtSecret` | JWT secret | `""` (auto-generated) |
| `config.sessionSecret` | Session secret | `""` (auto-generated) |
| `config.rateLimit.auth` | Auth rate limit | `10` |
| `config.rateLimit.ingestion` | Ingestion rate limit | `200` |
| `config.retention.logs` | Log retention (days) | `30` |
| `config.smtp.enabled` | Enable SMTP | `false` |

### Monitoring

| Parameter | Description | Default |
|-----------|-------------|---------|
| `metrics.enabled` | Enable metrics | `true` |
| `metrics.serviceMonitor.enabled` | Enable ServiceMonitor | `false` |
| `metrics.serviceMonitor.interval` | Scrape interval | `30s` |

## Persistence

Both TimescaleDB and Redis use PersistentVolumeClaims for data persistence. Make sure your cluster has a storage provisioner available.

## Security

- All secrets are auto-generated if not provided
- Pods run as non-root user (UID 1000)
- Network policies can be enabled for pod-to-pod communication control
- Service mesh support (Istio/Linkerd) available

## Upgrading

```bash
helm upgrade logtide ./logtide --namespace logtide
```

## Uninstalling

```bash
helm uninstall logtide --namespace logtide
```
