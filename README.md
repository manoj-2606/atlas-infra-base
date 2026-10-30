# atlas-infra-base

Reusable Terraform module that provisions the shared Azure infrastructure for every project in the Atlas Platform portfolio (P1–P11).

One module call gives you a tagged Resource Group, VNet, AKS cluster, and ACR — ready to deploy workloads.

## What It Provisions

| Resource | Configuration | Why |
|---|---|---|
| Resource Group | `rg-{project}-{env}` | Isolation per project, clean destroy |
| Virtual Network | `10.0.0.0/16` | Standard private address space |
| AKS Subnet | `10.0.1.0/24` (254 IPs) | Dedicated subnet for pod networking (Azure CNI) |
| AKS Cluster | 1 node, Standard_B2s, SystemAssigned identity | Cheapest viable config for non-prod (~₹3.5/hr) |
| Container Registry | Basic SKU, admin disabled | Image storage. AKS authenticates via AcrPull role assignment |
| Cost Tags | project, environment, team, cost-center, created-by, managed-by | FinOps attribution on every resource from Day 1 |

## Architecture

```
┌──────────────────────────────────────────────────┐
│  Resource Group: rg-{project}-{env}              │
│                                                  │
│  ┌──────────────────────────────────────────┐    │
│  │  VNet: 10.0.0.0/16                       │    │
│  │                                          │    │
│  │  ┌──────────────────────────────────┐    │    │
│  │  │  Subnet: 10.0.1.0/24 (AKS)      │    │    │
│  │  │                                  │    │    │
│  │  │  ┌────────────────────────┐      │    │    │
│  │  │  │  AKS Cluster           │      │    │    │
│  │  │  │  1x Standard_B2s node  │      │    │    │
│  │  │  │  Azure CNI             │      │    │    │
│  │  │  │  SystemAssigned MI ────┼──────┼────┼──► ACR (AcrPull)
│  │  │  └────────────────────────┘      │    │    │
│  │  └──────────────────────────────────┘    │    │
│  └──────────────────────────────────────────┘    │
│                                                  │
│  ACR: acr{project}{env} (Basic SKU)              │
└──────────────────────────────────────────────────┘
```

## Usage

```hcl
module "base" {
  source              = "../atlas-infra-base"
  project_name        = "atlas-06-observability"
  environment         = "dev"
  location            = "centralindia"
  aks_node_count      = 1
  aks_node_size       = "Standard_B2s"
}

# Access outputs
output "acr_server" {
  value = module.base.acr_login_server
}
```

## Inputs

| Variable | Type | Default | Description |
|---|---|---|---|
| `project_name` | string | *required* | Project name for resource naming |
| `environment` | string | `"dev"` | Environment (dev/staging/prod) |
| `location` | string | `"centralindia"` | Azure region |
| `aks_node_count` | number | `1` | Nodes in system pool |
| `aks_node_size` | string | `"Standard_B2s"` | VM SKU for AKS nodes |
| `aks_kubernetes_version` | string | `"1.30"` | Kubernetes version |
| `vnet_address_space` | list(string) | `["10.0.0.0/16"]` | VNet CIDR |
| `aks_subnet_prefix` | list(string) | `["10.0.1.0/24"]` | AKS subnet CIDR |
| `acr_sku` | string | `"Basic"` | ACR pricing tier |
| `cost_center` | string | `"atlas-platform"` | FinOps cost center tag |
| `created_by` | string | `"terraform"` | Creator tag |

## Outputs

| Output | Description |
|---|---|
| `resource_group_name` | Resource group name |
| `aks_cluster_name` | AKS cluster name |
| `aks_cluster_id` | AKS cluster resource ID |
| `kube_config_raw` | Raw kubeconfig (sensitive) |
| `acr_login_server` | ACR login URL |
| `acr_name` | ACR name |
| `acr_id` | ACR resource ID |
| `vnet_id` | VNet resource ID |
| `aks_subnet_id` | AKS subnet resource ID |
| `aks_identity_principal_id` | AKS managed identity principal ID |

## Cost (per project day, ~8 hours)

| Resource | Cost |
|---|---|
| AKS control plane | Free |
| 1x Standard_B2s node | ~₹3.5/hr = ~₹28/day |
| ACR Basic | ~₹15/day |
| VNet / NSG | Free |
| **Total** | **~₹45-50 per project day** |

## FinOps Design Decisions

- **Standard_B2s over D2s** — B-series is burstable, 60% cheaper than D-series. Sufficient for non-prod workloads. Prod projects (P11) override to D4s via `aks_node_size` variable.
- **Basic ACR over Standard** — No geo-replication needed for a portfolio. Basic = ₹15/day vs Standard = ₹60/day.
- **Cost tags on every resource** — `local.default_tags` applied to all resources via `tags.tf`. Enables cost queries by project, environment, team, and cost center in Azure Cost Management.
- **30GB OS disk** — Default is 128GB. Non-prod clusters don't need it. Saves ~₹5/day.

## Security

- **AKS uses SystemAssigned managed identity** — no service principal, no credential rotation.
- **ACR admin disabled** — AKS authenticates via AcrPull role assignment on kubelet identity.
- **gitleaks pre-commit hook** — secrets never reach Git history.
- **State files excluded in .gitignore** — tfstate contains secrets in plaintext.

## Cleanup

```bash
# From the consuming project directory (not this module)
terraform destroy -auto-approve

# Verify in Azure Portal → Resource Groups → confirm empty
```

> **Critical:** Always verify in Azure Portal after destroy. Terraform occasionally misses resources with delete locks or dependencies.

## Repo Structure

```
atlas-infra-base/
├── versions.tf              # Terraform + provider version constraints
├── variables.tf             # All configurable inputs
├── tags.tf                  # Default cost tags (FinOps)
├── resource-group.tf        # Resource Group
├── networking.tf            # VNet + AKS Subnet
├── acr.tf                   # Container Registry
├── aks.tf                   # AKS Cluster + ACR role assignment
├── outputs.tf               # Outputs consumed by other projects
├── .pre-commit-config.yaml  # gitleaks
├── .gitignore               # Terraform-specific ignores
└── README.md
```

## Author

**Manoj Kumar R** — Senior DevOps / Platform Engineer
[GitHub](https://github.com/manoj-2606) · [LinkedIn](https://linkedin.com/in/manoj2606)