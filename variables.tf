variable "project_name" {
  description = "Project name used in resource naming (e.g., atlas-06-observability)"
  type        = string
}

variable "environment" {
  description = "Environment identifier (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "centralindia"
}

variable "aks_node_count" {
  description = "Number of nodes in the default system pool"
  type        = number
  default     = 1
}

variable "aks_node_size" {
  description = "VM SKU for AKS nodes (B2s = cheapest for non-prod)"
  type        = string
  default     = "Standard_B2s"
}

variable "aks_kubernetes_version" {
  description = "Kubernetes version for AKS cluster"
  type        = string
  default     = "1.30"
}

variable "vnet_address_space" {
  description = "Address space for the VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_prefix" {
  description = "Subnet CIDR for AKS nodes"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "acr_sku" {
  description = "ACR pricing tier (Basic = cheapest)"
  type        = string
  default     = "Basic"
}

variable "cost_center" {
  description = "Cost center tag for FinOps attribution"
  type        = string
  default     = "atlas-platform"
}

variable "created_by" {
  description = "Creator tag for resource ownership tracking"
  type        = string
  default     = "terraform"
}
