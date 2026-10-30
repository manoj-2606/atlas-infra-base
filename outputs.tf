output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "aks_cluster_id" {
  description = "Resource ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "kube_config_raw" {
  description = "Raw kubeconfig for kubectl access"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "acr_login_server" {
  description = "ACR login server URL (e.g., acratlasdev.azurecr.io)"
  value       = azurerm_container_registry.main.login_server
}

output "acr_name" {
  description = "ACR name for az acr login"
  value       = azurerm_container_registry.main.name
}

output "acr_id" {
  description = "Resource ID of the ACR"
  value       = azurerm_container_registry.main.id
}

output "vnet_id" {
  description = "Resource ID of the VNet"
  value       = azurerm_virtual_network.main.id
}

output "aks_subnet_id" {
  description = "Resource ID of the AKS subnet"
  value       = azurerm_subnet.aks.id
}

output "aks_identity_principal_id" {
  description = "Principal ID of AKS managed identity"
  value       = azurerm_kubernetes_cluster.main.identity[0].principal_id
}