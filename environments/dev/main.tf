# Terraform Configuration for Dev Environment
# Azure Kubernetes Service and supporting infrastructure

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Backend configuration (Azure Storage - debe ser configurado)
  # backend "azurerm" {
  #   resource_group_name  = "ecommerce-terraform-state-rg"
  #   storage_account_name = "ecommercetfstate"
  #   container_name       = "tfstate"
  #   key                  = "dev.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "ecommerce" {
  name     = "ecommerce-dev-rg"
  location = var.location
  tags = {
    environment = "dev"
    project     = "ecommerce"
    managed_by  = "terraform"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "ecommerce" {
  name                = "ecommerce-dev-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.ecommerce.location
  resource_group_name = azurerm_resource_group.ecommerce.name
  tags = azurerm_resource_group.ecommerce.tags
}

# Subnet for AKS
resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.ecommerce.name
  virtual_network_name = azurerm_virtual_network.ecommerce.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Azure Kubernetes Service (AKS)
resource "azurerm_kubernetes_cluster" "ecommerce" {
  name                = "ecommerce-dev-aks"
  location            = azurerm_resource_group.ecommerce.location
  resource_group_name = azurerm_resource_group.ecommerce.name
  dns_prefix          = "ecommerce-dev"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name            = "default"
    node_count      = var.node_count
    vm_size         = var.node_size
    os_disk_size_gb = 30
    vnet_subnet_id  = azurerm_subnet.aks.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = azurerm_resource_group.ecommerce.tags
}

# Outputs
output "resource_group_name" {
  value = azurerm_resource_group.ecommerce.name
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.ecommerce.name
}

output "aks_fqdn" {
  value = azurerm_kubernetes_cluster.ecommerce.fqdn
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.ecommerce.kube_config_raw
  sensitive = true
}

