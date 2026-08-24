output "resource_group_name" {
  value       = azurerm_resource_group.aks.name
  description = "Resource Group Name"
}

output "aks_cluster_name" {
  value       = azurerm_kubernetes_cluster.aks.name
  description = "AKS Cluster Name"
}

output "aks_oidc_issuer_url" {
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  description = "AKS OIDC Issuer URL for Workload Identity"
}
output "key_vault_name" {
  value       = azurerm_key_vault.kv.name
  description = "Name of the created Azure Key Vault"
}

output "workload_identity_client_id" {
  value       = azurerm_user_assigned_identity.aks_workload_identity.client_id
  description = "Client ID of the User Assigned Identity for Workload Identity"
}