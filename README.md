# Azure VM Portfolio Project

This project demonstrates how to deploy a **Linux VM on Azure** using **Bicep**, configure it with **Ansible**, and run a sample application via **Docker and Nginx**. It is designed as a portfolio example showing **IaC + CI/CD** workflow.

---

## 📁 Project Structure

```
.
├── README.md
├── default.yaml             # Default tags and configuration
├── main.azcli               # CLI automation script for Azure deploy
├── main.bicep               # Main Bicep template for Azure resources
├── modules                  # Reusable Bicep modules
│   ├── disk.bicep
│   ├── public-ip.bicep
│   ├── vm.bicep
│   ├── vnet.bicep
│   └── vnic.bicep
├── playbooks                # Ansible playbooks
│   └── setup-vm.yml
└── roles
    ├── app                  # Deploy sample application container
    │   └── tasks
    │       └── main.yaml
    ├── docker               # Install and configure Docker
    │   └── tasks
    │       └── main.yaml
    └── nginx                # Install and configure Nginx
        └── tasks
            └── main.yaml
```

---

## 🛠 Features

* **Azure Infrastructure**

  * Resource Group
  * Virtual Network (VNet) + Subnet
  * Public IP
  * Network Interface (NIC)
  * Managed Disk
  * Linux Virtual Machine with SSH key login

* **Configuration via Ansible**

  * Docker installation
  * Nginx installation
  * Deploy sample container application

* **CI/CD Ready**

  * GitHub Actions workflow to deploy infrastructure
  * GitHub Actions workflow to configure VM with Ansible

---

## ⚡ Prerequisites

* Azure account
* Subscription ID
* SSH key pair (`~/.ssh/id_rsa` / `~/.ssh/id_rsa.pub`)
* GitHub repository with **Secrets**:

  * `AZURE_CREDENTIALS` → Service Principal JSON
  * `SSH_PUBLIC_KEY` → Public SSH key
  * `SSH_PRIVATE_KEY` → Private SSH key for Ansible
  * `VM_PUBLIC_IP` → Populated after Bicep deploy (for manual Ansible runs)

---

## 1️⃣ Generate Azure Credentials (Service Principal)

```bash
az ad sp create-for-rbac --name "portfolio-sp" --role Contributor --scopes /subscriptions/<SUBSCRIPTION_ID>
```

This outputs JSON:

```json
{
  "appId": "...",
  "displayName": "portfolio-sp",
  "password": "...",
  "tenant": "..."
}
```

> Save this JSON as GitHub secret `AZURE_CREDENTIALS`.

---

## 2️⃣ Login and Set Subscription

```bash
az login --use-device-code
az account set --subscription "<SUBSCRIPTION_ID>"
```

---

## 3️⃣ Install and Verify Bicep

```bash
az bicep install --version v0.39.26
az bicep version
```

---

## 4️⃣ Deploy Azure Infrastructure (Bicep)

### Using CLI (`main.azcli`):

```bash
# Dry-run
az deployment sub what-if --location eastus2 --template-file main.bicep

# Validate template
az deployment sub validate --location eastus2 --template-file main.bicep

# Deploy
az deployment sub create \
  --location eastus2 \
  --template-file main.bicep \
  --parameters sshPublicKey="$(cat ~/.ssh/id_rsa.pub)" \
  --mode Complete
```

### Using GitHub Actions

* Workflow: `.github/workflows/deploy-infra.yml`
* Automatically deploys infrastructure to Azure
* Captures outputs: `resourceGroup` and `vmPublicIp`

---

## 5️⃣ Configure VM via Ansible

### Inventory (`inventory.ini` example)

```ini
[web]
VM_PUBLIC_IP ansible_user=azureuseradminfoo ansible_ssh_private_key_file=~/.ssh/id_rsa
```

### Run Playbook Locally

```bash
ansible-playbook -i inventory.ini playbooks/setup-vm.yml
```

### GitHub Actions Workflow

* Workflow: `.github/workflows/configure-vm-ansible.yml`
* Installs Docker, Nginx, and deploys a sample container automatically

---

## 6️⃣ Verify Deployment

* SSH into the VM:

```bash
ssh azureuseradminfoo@<VM_PUBLIC_IP>
```

* Access sample app:

```
http://<VM_PUBLIC_IP>:8080
```

* Verify Docker containers:

```bash
docker ps
```

---

## 7️⃣ Cleanup

Remove all resources to avoid costs:

```bash
az group delete --name "<RESOURCE_GROUP_NAME>" --yes --no-wait
```

---

## 📝 Notes

* Linux-only VM with SSH key authentication (no password)
* Always test `what-if` before deployment
* GitHub Actions workflows are designed for manual trigger (`workflow_dispatch`)
* Playbooks are modular using roles for **Docker**, **Nginx**, and **App**

---

## 📌 References

* [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/overview)
* [Deploy Azure Templates with CLI](https://learn.microsoft.com/azure/azure-resource-manager/templates/deploy-cli)
* [SSH Key Login for Linux VMs](https://learn.microsoft.com/azure/virtual-machines/linux/mac-create-ssh-keys)
* [Ansible Documentation](https://docs.ansible.com/)

---

✅ This setup demonstrates **full Azure IaC + VM configuration**, perfect for showcasing **DevOps skills in cloud automation**.
