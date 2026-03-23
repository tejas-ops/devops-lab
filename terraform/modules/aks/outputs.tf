output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "kube_config" {
  description = "Raw kubeconfig — used by kubectl and the CD pipeline"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true                   # won't print in terraform output, but can be read
}

output "cluster_identity" {
  description = "Managed identity object ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
