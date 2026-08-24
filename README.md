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
