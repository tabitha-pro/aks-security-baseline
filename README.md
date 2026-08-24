# 🔒 AKS Security Baseline & Azure Key Vault Integration

A step-by-step security implementation showcasing how to secure an **Azure Kubernetes Service (AKS)** cluster using Infrastructure as Code (**Terraform**), **Azure Workload Identity**, and the **Secrets Store CSI Driver**.

This repository demonstrates how to manage cloud infrastructure and container workloads following zero-trust security principles—without hardcoding secrets or API keys anywhere in code.

---

## 🎯 What This Project Accomplishes

* **Zero Hardcoded Credentials:** The application pod authenticates to Azure Key Vault securely using **OIDC Workload Identity Federation** instead of static passwords, tokens, or Service Principal secrets.
* **Secure Secret Injection:** Secrets are retrieved from Azure Key Vault at pod startup and mounted directly into memory as read-only files using the **Secrets Store CSI Driver**.
* **Hardened Pod Security Context:** Enforces Kubernetes security best practices to prevent unauthorized privilege escalation and root access inside the container:
  * `readOnlyRootFilesystem: true`
  * `runAsNonRoot: true` (UID `101`)
  * `allowPrivilegeEscalation: false`
  * Linux capabilities dropped: `ALL`

---

## 📁 Repository Structure

```text
aks-security-baseline/
├── k8s/
│   ├── 01-namespace.yaml             # Creates the isolated 'security-lab' namespace
│   ├── 02-hardened-deployment.yaml   # Hardened web application baseline deployment
│   ├── 03-network-policy.yaml        # Restricts ingress traffic to allowed services
│   ├── 04-service.yaml               # ClusterIP service exposing the web deployment
│   ├── 05-workload-identity.yaml     # ServiceAccount & SecretProviderClass definitions
│   └── 06-secure-deployment.yaml     # Pod configuration with CSI volume mount & unprivileged runtime
└── terraform/
    ├── main.tf                       # Provisioning AKS, Azure Key Vault, User Assigned Identity, & RBAC
    ├── outputs.tf                    # Cluster details, OIDC Issuer URL, and Key Vault ID
    ├── providers.tf                  # AzureRM and Helm/Kubernetes provider setup
    └── variables.tf                  # Configurable deployment inputs and Azure regions

🚀 How It Works (Step-by-Step)

1. Infrastructure Provisioning (/terraform)
Cluster Deployment: Terraform provisions an AKS cluster configured with OIDC Issuer and Workload Identity enabled.

Vault & Identity Setup: An Azure Key Vault instance and a User Assigned Managed Identity are deployed.

Least-Privilege RBAC: Fine-grained Azure RBAC roles (Key Vault Secrets User) are assigned to the Managed Identity, scoped specifically to the Key Vault.

2. Passwordless Authentication (k8s/05-workload-identity.yaml)
ServiceAccount Annotation: A Kubernetes ServiceAccount is annotated with the Azure Managed Identity Client ID.

Federated Identity Trust: Azure establishes a federated identity trust between the AKS OIDC Issuer URL and the Azure Managed Identity.

3. Hardened Deployment & Secret Mounting (k8s/06-secure-deployment.yaml)
CSI Provider Integration: The SecretProviderClass configures the CSI driver to fetch db-password from Azure Key Vault.

Secure Volume Mounting: An unprivileged container (nginxinc/nginx-unprivileged:alpine) mounts the secret in a read-only volume (/mnt/secrets-store).

Runtime Memory Buffer: An emptyDir memory volume is mounted at /tmp so the container can operate safely under readOnlyRootFilesystem: true.

🧪 Verification & Testing
To verify that secrets are successfully mounted without exposing credentials in environment variables, inspect the secret directly inside the running container:

PowerShell:

PowerShell
kubectl exec -it deployment/secure-app -n security-lab -- cat /mnt/secrets-store/db-password
Expected Output:

Plaintext
SuperSecretP@ssw0rd123!
