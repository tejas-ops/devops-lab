# modules/aks/main.tf
# Creates the AKS cluster and grants it permission to pull from ACR

# -------------------------------------------------------
# AKS Cluster
# -------------------------------------------------------
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name

  # System-assigned managed identity — no service principal needed
  identity {
    type = "SystemAssigned"
  }

  # Default node pool — where your pods run
  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_vm_size

    # Enable auto-scaling between 1 and 3 nodes
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
  }

  # Network profile — Azure CNI gives pods real VNet IPs
  network_profile {
    network_plugin = "kubenet"        # simpler than Azure CNI, fine for learning
    load_balancer_sku = "standard"
  }

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# -------------------------------------------------------
# Grant AKS permission to pull images from ACR
# This replaces manually running: az aks update --attach-acr
# -------------------------------------------------------
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}
