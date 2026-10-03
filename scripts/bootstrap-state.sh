#!/usr/bin/env bash
# ============================================================
# bootstrap-state.sh — Create Azure remote state backend
# Run ONCE before your first terraform init
# ============================================================
set -euo pipefail

# ── Configuration ────────────────────────────────────────────
LOCATION="eastus"
RG_NAME="rg-tfstate"
CONTAINER_NAME="tfstate"
STATE_KEY="sentinel.tfstate"

# Storage account name: 3-24 chars, lowercase alphanumeric only.
# Base name must be short enough that base + 6-char suffix <= 24.
BASE_NAME="stsentinel"
SUFFIX="$(openssl rand -hex 3)"    # 6 hex chars
SA_NAME="${BASE_NAME}${SUFFIX}"
# Result: "stsentinel" (10) + 6 = 16 chars — plenty of headroom.

# ── Preflight checks ─────────────────────────────────────────
command -v az >/dev/null 2>&1 || {
  echo "❌ Azure CLI (az) not found. Install it first." >&2
  exit 1
}
command -v openssl >/dev/null 2>&1 || {
  echo "❌ openssl not found. Install it or replace the random suffix." >&2
  exit 1
}
az account show >/dev/null 2>&1 || {
  echo "❌ Not logged in. Run 'az login' first." >&2
  exit 1
}

SUB_ID="$(az account show --query id -o tsv)"
echo "==> Using subscription: $SUB_ID"
echo "==> Storage account name: $SA_NAME"
echo ""

# ── Resource group ───────────────────────────────────────────
if az group show --name "$RG_NAME" >/dev/null 2>&1; then
  echo "==> Resource group '$RG_NAME' already exists — skipping"
else
  echo "==> Creating resource group: $RG_NAME"
  az group create --name "$RG_NAME" --location "$LOCATION" \
    --tags project=az104-portfolio managed_by=script
fi

# ── Storage account ──────────────────────────────────────────
if az storage account show --name "$SA_NAME" --resource-group "$RG_NAME" >/dev/null 2>&1; then
  echo "==> Storage account '$SA_NAME' already exists — skipping"
else
  echo "==> Creating storage account: $SA_NAME"
  az storage account create \
    --name "$SA_NAME" \
    --resource-group "$RG_NAME" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2 \
    --min-tls-version TLS1_2 \
    --https-only true \
    --allow-blob-public-access false \
    --encryption-services blob
fi

# ── Blob container ───────────────────────────────────────────
echo "==> Creating blob container: $CONTAINER_NAME"
az storage container create \
  --name "$CONTAINER_NAME" \
  --account-name "$SA_NAME" \
  --auth-mode login \
  >/dev/null

# ── Grant the current user data-plane access ─────────────────
# Required for `terraform init` if using use_azuread_auth = true.
PRINCIPAL_ID="$(az ad signed-in-user show --query id -o tsv 2>/dev/null || true)"
if [[ -n "$PRINCIPAL_ID" ]]; then
  SA_ID="$(az storage account show --name "$SA_NAME" --resource-group "$RG_NAME" --query id -o tsv)"
  echo "==> Granting Storage Blob Data Contributor to current user"
  az role assignment create \
    --assignee "$PRINCIPAL_ID" \
    --role "Storage Blob Data Contributor" \
    --scope "$SA_ID" \
    >/dev/null 2>&1 || echo "   (Role assignment already exists or insufficient permissions — ignoring)"
fi

# ── Output ───────────────────────────────────────────────────
echo ""
echo "✅ Remote state backend ready!"
echo ""
echo "──────────────────────────────────────────────────────────"
echo "Paste this into the backend block in main.tf:"
echo ""
cat <<EOF
  backend "azurerm" {
    resource_group_name  = "$RG_NAME"
    storage_account_name = "$SA_NAME"
    container_name       = "$CONTAINER_NAME"
    key                  = "$STATE_KEY"
    use_azuread_auth     = true
  }
EOF
echo ""
echo "──────────────────────────────────────────────────────────"
echo "Then run:"
echo "  terraform init -reconfigure"
echo ""
echo "If 'use_azuread_auth' causes issues, fall back to the access key:"
echo "  export ARM_ACCESS_KEY=\$(az storage account keys list \\"
echo "    --resource-group $RG_NAME --account-name $SA_NAME \\"
echo "    --query '[0].value' -o tsv)"
