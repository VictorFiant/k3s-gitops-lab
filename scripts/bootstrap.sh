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

echo "================================================"
echo " K3s GitOps Lab - Pre-flight Check"
echo "================================================"

# Check required tools
echo ""
echo "Checking required tools..."

command -v kubectl  >/dev/null 2>&1 && pass "kubectl found"   || fail "kubectl not found"
command -v helm     >/dev/null 2>&1 && pass "helm found"      || fail "helm not found"
command -v terraform >/dev/null 2>&1 && pass "terraform found" || fail "terraform not found"
command -v git      >/dev/null 2>&1 && pass "git found"       || fail "git not found"
command -v docker   >/dev/null 2>&1 && pass "docker found"    || fail "docker not found"

# Check kubectl can reach the cluster
echo ""
echo "Checking cluster connectivity..."

kubectl cluster-info >/dev/null 2>&1 && pass "cluster reachable" || fail "cannot reach cluster"

# Check ArgoCD is running
echo ""
echo "Checking ArgoCD..."

kubectl get namespace argocd >/dev/null 2>&1 && pass "argocd namespace exists" || fail "argocd namespace not found"
kubectl get pods -n argocd --field-selector=status.phase=Running --no-headers | grep -q "." && pass "argocd pods running" || fail "no argocd pods running"

# Check monitoring namespace
echo ""
echo "Checking observability stack..."

kubectl get namespace monitoring >/dev/null 2>&1 && pass "monitoring namespace exists" || fail "monitoring namespace not found"
kubectl get pods -n monitoring --field-selector=status.phase=Running --no-headers | grep -q "." && pass "monitoring pods running" || fail "no monitoring pods running"

echo ""
echo "================================================"
echo " All checks passed. Cluster is ready."
echo "================================================"