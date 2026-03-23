# variables.tf — all inputs for the root module
# Set values in terraform.tfvars (never commit that file if it has secrets)

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "uksouth"              # closest to London — matches your CV location
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "devops-lab-rg"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "devops-lab-aks"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "node_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_B2s"        # 2 vCPU, 4GB RAM — cheap for learning
}

variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique)"
  type        = string
  default     = "devopslabacr"
}

variable "environment" {
  description = "Environment tag applied to all resources"
  type        = string
  default     = "dev"
}
