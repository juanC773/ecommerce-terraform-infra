output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.ecommerce.name
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.ecommerce.name
}

output "aks_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.ecommerce.fqdn
}

output "kube_config_raw" {
  description = "Raw Kubernetes config"
  value       = azurerm_kubernetes_cluster.ecommerce.kube_config_raw
  sensitive   = true
}

