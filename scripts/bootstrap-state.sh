#!/usr/bin/env bash
# ============================================================
# bootstrap-state.sh — Create Azure remote state backend
# Run ONCE before your first terraform init
# ============================================================
set -euo pipefail

LOCATION="eastus"
RG_NAME="rg-tfstate"
SA_NAME="stterraformstate$(openssl rand -hex 4)"
CONTAINER_NAME="tfstate"

echo "==> Creating resource group: $RG_NAME"
az group create --name "$RG_NAME" --location "$LOCATION" \
  --tags project=az104-portfolio managed_by=script

echo "==> Creating storage account: $SA_NAME"
az storage account create \
  --name "$SA_NAME" \
  --resource-group "$RG_NAME" \
  --location "$LOCATION" \
  --sku Standard_LRS \
  --kind StorageV2 \
  --min-tls-version TLS1_2 \
  --https-only true \
  --allow-blob-public-access false

echo "==> Creating blob container: $CONTAINER_NAME"
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$SA_NAME" \
  --auth-mode login

echo ""
echo "✅ Remote state backend ready!"
echo ""
echo "Uncomment and update the backend block in main.tf:"
echo "  resource_group_name  = \"$RG_NAME\""
echo "  storage_account_name = \"$SA_NAME\""
echo "  container_name       = \"$CONTAINER_NAME\""
echo "  key                  = \"sentinel.tfstate\""
echo ""
echo "Then run: terraform init -reconfigure"
