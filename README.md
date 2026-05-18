# 🛡️ Azure Infrastructure Sentinel — Terraform Edition

<div align="center">

![Terraform](https://img.shields.io/badge/Terraform-1.6+-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI%2FCD-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![AZ-104](https://img.shields.io/badge/AZ--104-Certified-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)
![Terraform Associate](https://img.shields.io/badge/Terraform-Associate-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)

**Production-grade Azure infrastructure using Terraform modules, remote state, and a full CI/CD pipeline.**  
The Terraform counterpart to the [Bicep edition](https://github.com/YOUR_USERNAME/azure-sentinel) — identical infrastructure, different IaC philosophy.

[Deploy Now](#-quick-start) · [Architecture](#-architecture) · [Module Docs](#-modules) · [CI/CD](#-cicd-pipeline)

</div>

---

## 📋 What This Project Demonstrates

| Skill Domain | Coverage |
|---|---|
| **AZ-104: Networking** | Hub VNet, 5 subnets, tiered NSGs, service endpoints, Bastion-ready |
| **AZ-104: Storage** | Secure Storage Account — HTTPS-only, no public blob, TLS 1.2, VNet rules, GRS for prod |
| **AZ-104: Key Vault** | RBAC auth, soft delete, purge protection (prod), network ACLs |
| **AZ-104: Compute** | Ubuntu 22.04, Trusted Launch, managed identity, OMS agent, auto-shutdown |
| **AZ-104: Monitoring** | Log Analytics Workspace, diagnostic settings on all resources |
| **Terraform Associate** | Modules, remote state, variables/outputs, `count` meta-argument, `sensitive`, `validation`, provider features |

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                    Azure Resource Group                          │
│                                                                  │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │              Virtual Network (10.0.0.0/16)              │   │
│   │                                                         │   │
│   │  ┌─────────────┐  ┌─────────────┐  ┌───────────────┐  │   │
│   │  │  snet-front │  │ snet-backend│  │   snet-data   │  │   │
│   │  │ 10.0.1.0/24 │  │ 10.0.2.0/24│  │ 10.0.3.0/24   │  │   │
│   │  │  NSG: 443✅  │  │ NSG: 8080  │  │ NSG: 1433     │  │   │
│   │  │  NSG: 80 ✅  │  │  from front│  │  from backend │  │   │
│   │  │  SvcEndpoint │  │  KV Endpt  │  │  SQL+Storage  │  │   │
│   │  └─────────────┘  └─────────────┘  └───────────────┘  │   │
│   │                                                         │   │
│   │  ┌──────────────────┐  ┌──────────────────────────┐   │   │
│   │  │  snet-management │  │   AzureBastionSubnet     │   │   │
│   │  │  10.0.4.0/24     │  │   10.0.5.0/26            │   │   │
│   │  │  NSG: SSH/RDP    │  │   (Bastion host ready)   │   │   │
│   │  │  admin IP only   │  │                          │   │   │
│   │  └──────────────────┘  └──────────────────────────┘   │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│   ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐ │
│   │ Storage Acct │  │  Key Vault   │  │  Log Analytics       │ │
│   │ HTTPS-only   │  │  RBAC auth   │  │  Workspace           │ │
│   │ No pub blob  │  │  Soft delete │  │  30/90-day retain    │ │
│   │ TLS 1.2+     │  │  VNet locked │  │  All diag routed     │ │
│   │ LRS/GRS*     │  │  Purge prot* │  │  here                │ │
│   └──────────────┘  └──────────────┘  └──────────────────────┘ │
│                          *prod only                              │
└──────────────────────────────────────────────────────────────────┘

Terraform State → Azure Blob Storage (remote backend)
CI/CD          → GitHub Actions (validate → plan → apply → destroy)
```

---

## 📦 Modules

```
azure-sentinel-terraform/
├── main.tf                          # Root: orchestrates all modules
├── variables.tf                     # All input variables with validation
├── outputs.tf                       # All root outputs
├── modules/
│   ├── vnet/                        # VNet, 5 subnets, 4 NSGs, associations
│   ├── storage/                     # Storage Account + diagnostic settings
│   ├── keyvault/                    # Key Vault + RBAC + diagnostic settings
│   ├── vm/                          # Linux VM + OMS agent + auto-shutdown
│   └── monitoring/                  # Log Analytics Workspace
├── environments/
│   └── dev/
│       └── terraform.tfvars.example # Dev environment variable values
├── scripts/
│   └── bootstrap-state.sh           # One-time remote state backend setup
└── .github/workflows/
    └── terraform.yml                # CI/CD: validate → plan → apply → destroy
```

### Module Dependency Graph

```
monitoring  ←──────────────────────────────────┐
    ↑                                           │
   vnet                                         │
    ↑           ↑           ↑                   │
 storage    keyvault       vm ──────────────────┘
```

---

## 🚀 Quick Start

### Prerequisites

```bash
terraform --version   # 1.6+
az --version          # Azure CLI 2.50+
az login
```

### 1. Bootstrap Remote State (one-time)

```bash
chmod +x scripts/bootstrap-state.sh
./scripts/bootstrap-state.sh

# Copy the output into the backend block in main.tf
# Then uncomment the backend block
```

### 2. Configure Variables

```bash
cp environments/dev/terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and replace `YOUR_IP/32` with your actual IP:

```bash
# Find your IP:
curl ifconfig.me
```

> ⚠️ `terraform.tfvars` is in `.gitignore` — it will never be committed.

### 3. Initialize

```bash
terraform init
```

### 4. Plan (dry run)

```bash
terraform plan
```

### 5. Apply

```bash
terraform apply
```

Type `yes` when prompted. Deployment takes ~2 minutes.

### 6. Destroy (avoid charges)

```bash
terraform destroy
```

---

## ⚙️ CI/CD Pipeline

GitHub Actions runs four jobs on every push:

```
Push to main / PR
       │
       ▼
 ┌─────────────┐
 │  Validate   │  terraform fmt + validate (no backend needed)
 └──────┬──────┘
        │
        ▼
 ┌─────────────┐
 │    Plan     │  terraform plan → artifact + PR comment
 └──────┬──────┘
        │ (main branch only)
        ▼
 ┌─────────────┐
 │    Apply    │  terraform apply -auto-approve (uses saved plan)
 └─────────────┘

  Manual only:
 ┌─────────────┐
 │   Destroy   │  dev environment only, requires approval gate
 └─────────────┘
```

### GitHub Secrets Required

| Secret | Description |
|---|---|
| `ARM_CLIENT_ID` | Service principal App ID |
| `ARM_CLIENT_SECRET` | Service principal secret |
| `ARM_SUBSCRIPTION_ID` | Your Azure subscription ID |
| `ARM_TENANT_ID` | Your Azure tenant ID |
| `ADMIN_CIDR` | Your IP (e.g. `203.0.113.5/32`) |
| `VM_ADMIN_PASSWORD` | VM password (if deploying VM) |

### Create Service Principal

```bash
az ad sp create-for-rbac \
  --name "sp-sentinel-terraform" \
  --role "Contributor" \
  --scopes "/subscriptions/$(az account show --query id -o tsv)"

# Add each output value as a GitHub secret:
# appId       → ARM_CLIENT_ID
# password    → ARM_CLIENT_SECRET
# tenant      → ARM_TENANT_ID
```

---

## 🔑 Key Terraform Concepts Demonstrated

**Module Architecture**
- Five reusable child modules, each self-contained with `variables.tf`, `main.tf`, `outputs.tf`
- Root module orchestrates dependencies via output references (`module.vnet.subnet_ids`)
- Module `count` meta-argument for conditional VM deployment

**Variables & Validation**
- `sensitive = true` on passwords and CIDRs
- `validation` blocks with `cidrhost()` and `contains()` for input safety
- `default` values with environment-appropriate overrides

**State Management**
- Remote state backend in Azure Blob Storage (encrypted at rest)
- State locking via Azure Blob lease (prevents concurrent applies)
- Bootstrap script for one-time backend provisioning

**Provider Configuration**
- `azurerm` provider features block with environment-aware purge/delete settings
- `random_string` for globally unique resource name suffixes
- `data "azurerm_client_config"` for dynamic tenant ID resolution

**Outputs**
- Structured outputs at both module and root level
- `sensitive = true` on workspace primary key output
- Null-safe conditional output for optional VM (`var.deploy_vm ? ... : null`)

---

## 💰 Estimated Cost (Dev, No VM)

| Resource | SKU | Est. Monthly |
|---|---|---|
| VNet + NSGs | Free | $0.00 |
| Storage Account | Standard_LRS | ~$0.02 |
| Key Vault | Standard | ~$0.03 |
| Log Analytics | Pay-per-GB | ~$0.00 |
| Remote State Storage | Standard_LRS | ~$0.01 |
| **Total** | | **< $1/month** |

> Adding the VM costs ~$30–40/month for `Standard_B2s`. Auto-shutdown at 23:00 UTC is configured.

---

## 🔄 Bicep vs Terraform

| | [Bicep Edition](https://github.com/YOUR_USERNAME/azure-sentinel) | Terraform Edition |
|---|---|---|
| **Language** | Bicep (Azure-native DSL) | HCL (cloud-agnostic) |
| **State** | Managed by Azure | Remote in Blob Storage |
| **Modules** | Bicep modules | Terraform modules |
| **Plan** | `what-if` | `terraform plan` |
| **Provider** | Always Azure | Azure via `azurerm` |
| **Portability** | Azure only | Multi-cloud capable |
| **AZ-104 relevance** | Native ARM alignment | Industry-standard IaC |

Both deploy **identical infrastructure**. The Bicep edition shows Azure-native fluency. This edition shows tool-agnostic IaC skills — more valuable on a resume for roles that aren't Azure-exclusive.

---

## 📜 License

MIT — use freely, attribution appreciated.

---

<div align="center">

Built by **Fred Mann** | AZ-104 Certified · Terraform Associate (renewing)  
[LinkedIn](https://linkedin.com/in/fredmann) · [Bicep Edition](https://github.com/YOUR_USERNAME/azure-sentinel)

</div>
