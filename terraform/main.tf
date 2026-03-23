# main.tf — root module
# Wires together the provider, resource group, ACR, and AKS module

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }

  # Remote state in Azure Blob Storage
  # Uncomment once you've created the storage account (see README)
  # backend "azurerm" {
  #   resource_group_name  = "devops-lab-tfstate-rg"
  #   storage_account_name = "devopslabtfstate"
  #   container_name       = "tfstate"
  #   key                  = "devops-lab.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# -------------------------------------------------------
# Resource Group — container for all resources
# -------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = var.environment
    project     = "devops-lab"
    managed_by  = "terraform"
  }
}

# -------------------------------------------------------
# Azure Container Registry — stores your Docker images
# -------------------------------------------------------
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"         # cheapest tier — fine for learning
  admin_enabled       = false           # use managed identity instead of admin password

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# -------------------------------------------------------
# AKS Cluster — via reusable module
# -------------------------------------------------------
module "aks" {
  source = "./modules/aks"

  cluster_name        = var.cluster_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  node_count          = var.node_count
  node_vm_size        = var.node_vm_size
  acr_id              = azurerm_container_registry.acr.id
  environment         = var.environment
}
