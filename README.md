# K3s GitOps Lab

## Overview

This repository implements a fully automated GitOps workflow for deploying and managing
applications on a self-hosted Kubernetes cluster. The infrastructure runs on a Hetzner
Cloud server (CX23, Ubuntu 24.04) and is managed entirely through Git.

Every component — from infrastructure provisioning to application deployment and
observability — is declared as code in this repository.

## Architecture

### GitOps Deployment Flow

Git is the single source of truth. No manual changes are applied to the cluster directly.

1. A developer pushes code to the repository
2. GitHub Actions builds and pushes a Docker image to Docker Hub
3. ArgoCD detects the change in Git
4. ArgoCD automatically synchronizes the cluster state with the repository
5. Applications are deployed and updated via Helm charts

This ensures:
- Reproducible deployments
- Full audit trail via Git history
- Automatic drift correction (selfHeal + prune enabled)

## Tech Stack

| Layer | Tool |
|---|---|
| Infrastructure | Hetzner Cloud + Terraform |
| Kubernetes | K3s |
| GitOps | ArgoCD |
| Application Packaging | Helm |
| CI Pipeline | GitHub Actions |
| Container Registry | Docker Hub |
| Metrics | Prometheus |
| Visualization | Grafana |
| Logging | Loki |
| Alerting | AlertManager |

## Repository Structure
```
k3s-gitops-lab
│
├── app/                        # Application source code
│   ├── Dockerfile
│   └── index.html
│
├── apps/
│   └── nginx-helm/             # Custom Helm chart
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── ingress.yaml
│           ├── hpa.yaml        # Horizontal Pod Autoscaler
│           ├── serviceaccount.yaml
│           └── _helpers.tpl
│
├── clusters/
│   └── dev/                    # ArgoCD Application manifests
│       ├── nginx-helm.yaml
│       ├── monitoring.yaml     # Prometheus stack
│       └── loki.yaml
│
├── terraform/                  # Infrastructure as Code
│   ├── main.tf                 # Hetzner Cloud server + firewall
│   ├── variables.tf
│   ├── outputs.tf
│   └── user_data.sh            # k3s bootstrap script
│
└── .github/
    └── workflows/
        └── ci.yaml             # Build and push Docker image
```

## Infrastructure

The server is provisioned using Terraform with the Hetzner Cloud provider.
```bash
cd terraform/
terraform init
terraform plan -var="hcloud_token=YOUR_TOKEN" -var="ssh_public_key=$(cat ~/.ssh/id_rsa.pub)"
terraform apply
```

This provisions a CX23 server on Hetzner Cloud with Ubuntu 24.04, installs k3s
automatically via cloud-init, and configures firewall rules for Kubernetes access.

## Kubernetes Deployment

Applications are deployed using a custom Helm chart managed by ArgoCD.

The nginx-helm chart includes a Horizontal Pod Autoscaler configured to scale
based on CPU utilization, a ServiceMonitor for Prometheus scraping, and an
Ingress resource for external access via Traefik.

ArgoCD is configured with `automated.selfHeal: true` and `automated.prune: true`,
meaning any manual change applied directly to the cluster will be automatically
reverted to match the Git state.

## Observability Stack

The cluster runs a full observability stack deployed via ArgoCD:

**Prometheus** collects metrics from all Kubernetes workloads and exposes them
via ServiceMonitors, including a custom ServiceMonitor for the nginx application.

**Grafana** provides dashboards for visualizing cluster and application metrics,
accessible at `http://<server-ip>:30263`.

**Loki** aggregates logs from all running pods and integrates with Grafana as
a data source.

**AlertManager** handles alert routing and is integrated with the Prometheus stack.

## CI Pipeline

On every push to `main`, GitHub Actions:
1. Builds the Docker image from `app/Dockerfile`
2. Pushes the image to Docker Hub as `fiantvictor/devops-nginx:latest`

ArgoCD then detects the updated image and redeploys the application automatically.

## Author

Victor Fiant — DevOps / Cloud Infrastructure