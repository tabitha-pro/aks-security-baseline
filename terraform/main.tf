resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    environment = "lab"
    project     = "aks-security-baseline"
    managed_by  = "terraform"
  }
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "aks-security-lab"

  sku_tier = "Free"

  default_node_pool {
    name       = "system"
    node_count = 1
    vm_size    = "Standard_D2ps_v5"
    os_disk_type = "Managed"
  }

  identity {
    type = "SystemAssigned"
  }

  # Critical Security Configurations for Workload Identity & OIDC
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  tags = {
    environment = "lab"
    project     = "aks-security-baseline"
    managed_by  = "terraform"
  }
}
# Generate random suffix for unique Key Vault name
resource "random_id" "kv_suffix" {
  byte_length = 4
}

# Azure Key Vault
resource "azurerm_key_vault" "kv" {
  name                        = "kv-aks-lab-${random_id.kv_suffix.hex}"
  location                    = azurerm_resource_group.aks.location
  resource_group_name         = azurerm_resource_group.aks.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  enable_rbac_authorization = true

  tags = {
    environment = "lab"
    managed_by  = "terraform"
    project     = "aks-security-baseline"
  }
}

# User-Assigned Managed Identity for AKS Workload Identity
resource "azurerm_user_assigned_identity" "aks_workload_identity" {
  name                = "uai-aks-workload"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
}

# Federated Credential linking Azure Identity to Kubernetes ServiceAccount
resource "azurerm_federated_identity_credential" "aks_federated" {
  name                = "fic-aks-workload"
  resource_group_name = azurerm_resource_group.aks.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.aks_workload_identity.id
  subject             = "system:serviceaccount:security-lab:workload-sa"
}

# Assign Key Vault Secrets User role to Managed Identity
resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.aks_workload_identity.principal_id
}