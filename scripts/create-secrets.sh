#!/bin/bash
# create-secrets.sh — creates K8s secrets from environment variables
# Usage: APP_SECRET_KEY=mysecret ./scripts/create-secrets.sh
#
# Why this approach?
#   - Never hardcode secrets in YAML files committed to git
#   - Env vars are set in CI/CD (GitHub Actions secrets) or locally in your shell
#   - kubectl create secret generates the base64 encoding automatically

set -e   # exit immediately if any command fails

NAMESPACE="devops-lab"

# Check required env vars are set
if [ -z "$APP_SECRET_KEY" ]; then
  echo "ERROR: APP_SECRET_KEY is not set"
  echo "Usage: APP_SECRET_KEY=mysecret ./scripts/create-secrets.sh"
  exit 1
fi

echo "Creating namespace if it doesn't exist..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "Creating secret..."
kubectl create secret generic devops-lab-secret \
  --namespace="$NAMESPACE" \
  --from-literal=APP_SECRET_KEY="$APP_SECRET_KEY" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secret created successfully."
echo ""
echo "Verify (shows keys only, not values):"
kubectl get secret devops-lab-secret -n "$NAMESPACE" -o jsonpath='{.data}' | python3 -c "
import sys, json
data = json.load(sys.stdin)
for key in data:
    print(f'  {key}: [REDACTED]')
"
