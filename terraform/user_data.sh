#!/bin/bash
set -euo pipefail

# Update system
apt-get update -y
apt-get upgrade -y

# Install k3s
curl -sfL https://get.k3s.io | sh -

# Wait for k3s to be ready
until kubectl get nodes | grep -q "Ready"; do
  echo "Waiting for k3s to be ready..."
  sleep 5
done

echo "k3s is ready"
```

---

También creá **`terraform/.gitignore`** para no commitear secretos:
```
*.tfstate
*.tfstate.backup
.terraform/
.terraform.lock.hcl
terraform.tfvars