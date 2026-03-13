#!/bin/bash
set -euo pipefail

# ============================================
# K3s GitOps Lab - Bootstrap Validation Script
# Validates that all required tools are
# installed before deploying the stack
# ============================================

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

pass() { echo -e "${GREEN}[OK]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }

check() {
  if eval "$1" >/dev/null 2>&1; then
    pass "$2"
  else
    fail "$3"
  fi
}

echo "================================================"
echo " K3s GitOps Lab - Pre-flight Check"
echo "================================================"

echo ""
echo "Checking required tools..."
check "command -v kubectl"   "kubectl found"   "kubectl not found"
check "command -v helm"      "helm found"      "helm not found"
check "command -v terraform" "terraform found" "terraform not found"
check "command -v git"       "git found"       "git not found"
check "command -v docker"    "docker found"    "docker not found"

echo ""
echo "Checking cluster connectivity..."
check "kubectl cluster-info" "cluster reachable" "cannot reach cluster"

echo ""
echo "Checking ArgoCD..."
check "kubectl get namespace argocd" "argocd namespace exists" "argocd namespace not found"
check "kubectl get pods -n argocd --field-selector=status.phase=Running --no-headers | grep -q ." "argocd pods running" "no argocd pods running"

echo ""
echo "Checking observability stack..."
check "kubectl get namespace monitoring" "monitoring namespace exists" "monitoring namespace not found"
check "kubectl get pods -n monitoring --field-selector=status.phase=Running --no-headers | grep -q ." "monitoring pods running" "no monitoring pods running"

echo ""
echo "================================================"
echo " All checks passed. Cluster is ready."
echo "================================================"