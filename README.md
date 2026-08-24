# 🔒 AKS Security Baseline & Azure Key Vault Integration

A step-by-step security implementation showcasing how to secure an **Azure Kubernetes Service (AKS)** cluster using Infrastructure as Code (**Terraform**), **Azure Workload Identity**, and the **Secrets Store CSI Driver**.

This repository demonstrates how to manage cloud infrastructure and container workloads following zero-trust security principles—without hardcoding secrets or API keys anywhere in code.

---

## 🎯 What This Project Accomplishes

* **Zero Hardcoded Credentials:** The application pod authenticates to Azure Key Vault securely using **OIDC Workload Identity Federation** instead of static passwords, tokens, or Service Principal secrets.
* **Secure Secret Injection:** Secrets are retrieved from Azure Key Vault at pod startup and mounted as read-only files using the Secrets Store CSI Driver, without exposing credentials through environment variables.
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

```
## 🚀 How It Works (Step-by-Step)

### 1. Infrastructure Provisioning (`/terraform`)

**Cluster Deployment:**  
Terraform provisions an AKS cluster configured with **OIDC Issuer** and **Workload Identity** enabled.

**Vault & Identity Setup:**  
An **Azure Key Vault** instance and a **User Assigned Managed Identity** are deployed.

**Least-Privilege RBAC:**  
Fine-grained Azure RBAC roles (`Key Vault Secrets User`) are assigned to the Managed Identity, scoped specifically to the Key Vault.

---

### 2. Passwordless Authentication (`k8s/05-workload-identity.yaml`)

**ServiceAccount Annotation:**  
A Kubernetes `ServiceAccount` is annotated with the Azure Managed Identity Client ID.

**Federated Identity Trust:**  
Azure establishes a federated identity trust between the **AKS OIDC Issuer URL** and the **Azure Managed Identity**.

---

### 3. Hardened Deployment & Secret Mounting (`k8s/06-secure-deployment.yaml`)

**CSI Provider Integration:**  
The `SecretProviderClass` configures the CSI driver to fetch `db-password` from **Azure Key Vault**.

**Secure Volume Mounting:**  
An unprivileged container (`nginxinc/nginx-unprivileged:alpine`) mounts the secret in a **read-only volume** (`/mnt/secrets-store`).

**Runtime Memory Buffer:**  
An `emptyDir` memory volume is mounted at `/tmp` so the container can operate safely under `readOnlyRootFilesystem: true`.

---

## 🧪 Verification & Testing

The deployment can be verified by confirming that the application successfully retrieves the secret from Azure Key Vault and mounts it inside the running container.

### 🔍 Verify Secret Mount

Run the following command in **PowerShell**:

```powershell
kubectl exec -it deployment/secure-app -n security-lab -- cat /mnt/secrets-store/db-password
```

### 🔑 Expected Secret Output

If the configuration is working correctly, the command returns the secret stored in Azure Key Vault:

```text
Secret successfully retrieved from Azure Key Vault.
```

> ⚠️ **Security Note:** This is a test credential created specifically for this security lab. Real production credentials should never be committed to source control.

---

## 🛡️ Security Controls Implemented

### 🔐 Identity & Access

- **Workload Identity + OIDC** — Enables passwordless authentication between AKS and Azure.
- **Managed Identity** — Eliminates hardcoded Azure credentials.
- **Azure RBAC** — Provides least-privilege `Key Vault Secrets User` access.

### 🔒 Secrets Management

- **Azure Key Vault** — Provides centralized secret management.
- **Secrets Store CSI Driver** — Retrieves secrets dynamically at runtime.

### 🛡️ Container Hardening

- **Non-Root Container** — Reduces container execution privileges.
- **Read-Only Filesystem** — Limits unauthorized filesystem modification.
- **Dropped Linux Capabilities** — Reduces the container attack surface.

---

## 🛠️ Key Technologies Used

| Category | Technologies |
|---|---|
| **Cloud** | Azure Kubernetes Service (AKS), Azure Key Vault, Azure Managed Identities |
| **Identity & Security** | Microsoft Entra Workload Identity (OIDC), Azure RBAC |
| **Infrastructure as Code** | Terraform |
| **Containers & Tooling** | Kubernetes, Secrets Store CSI Driver, Nginx, `kubectl`, Helm |

---

## 🚀 Push Changes to GitHub

After updating the README, commit and push your changes:

```powershell
git add README.md
git commit -m "docs: update security architecture README"
git push
```
