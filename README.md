# Deploy de Infraestrutura Azure com Bicep

Este projeto contém um template Bicep (`main.bicep`) para criar uma VM Linux completa, incluindo:

- Resource Group
- VNet + Subnet
- Public IP
- Network Interface (NIC)
- Managed Disk
- Virtual Machine Linux configurada com SSH key (sem senha)

Este README explica passo a passo como usar o arquivo `main.azcli` para automatizar o deploy.

---

## 1️⃣ Login no Azure

Antes de qualquer deploy, faça login na sua conta:

```bash
az login --use-device-code
````

> ⚡ Este comando abre um link e um código de dispositivo para autenticação.

---

## 2️⃣ Selecionar a Subscription

Escolha a subscription onde os recursos serão criados:

```bash
az account set --subscription '<SUBSCRIPTION_ID>'
```

Substitua `<SUBSCRIPTION_ID>` pelo ID ou nome da sua subscription.

---

## 3️⃣ Instalar e verificar o Bicep

Instale a versão necessária do Bicep:

```bash
az bicep install --version v0.39.26
```

Verifique se o Bicep foi instalado corretamente:

```bash
az bicep version
```

> Isso garante compatibilidade com o template.

---

## 4️⃣ Compilar o template Bicep para ARM JSON

Para gerar o arquivo JSON equivalente (opcional, mas útil para debug):

```bash
az bicep build --file main.bicep --outfile main.arm.json
```

Se quiser, é possível **decompilar** um ARM template de volta para Bicep:

```bash
az bicep decompile --file main.arm.json --force
```

---

## 5️⃣ Testar alterações sem aplicar (dry-run)

Para ver quais alterações serão feitas sem realmente criar recursos:

```bash
az deployment sub what-if --location eastus2 --template-file main.bicep
```

---

## 6️⃣ Validar template

Valida sintaxe, parâmetros e permissões:

```bash
az deployment sub validate --location eastus2 --template-file main.bicep
```

---

## 7️⃣ Criar ou atualizar a infraestrutura

⚠️ Sempre use `--mode Complete` em escopo de subscription para garantir que recursos obsoletos sejam removidos:

```bash
az deployment sub create \
  --location eastus2 \
  --template-file main.bicep \
  --parameters sshPublicKey="$(cat ~/.ssh/id_rsa.pub)" \
  --mode Complete
```

### Parâmetro importante:

* `sshPublicKey`: conteúdo da sua chave pública SSH (`~/.ssh/id_rsa.pub`)

  * Garante que você poderá logar na VM sem precisar de senha.

---

## 8️⃣ Obter informações da implantação

Exemplo: recuperar o nome do Resource Group criado:

```bash
az deployment sub show \
  --name main \
  --query properties.outputs.resourceGroupName.value -o tsv
```

Você pode usar o mesmo comando para obter outras outputs definidas no `main.bicep`.

---

## 9️⃣ Deletar o Resource Group (exemplo)

Para remover todos os recursos de forma limpa:

```bash
az group delete --name "RG-23DF1793-A23D-5476-863F-3E07B3550827" --yes --no-wait
```

> ⚠️ `--no-wait` faz o comando retornar imediatamente; recursos continuam sendo deletados em background.

---

## 🔑 Observações importantes

* Este template é **Linux-only** e **usa SSH key**. Não há senha configurada.
* Certifique-se de gerar uma chave SSH antes do deploy (`ssh-keygen -t rsa -b 4096`).
* Sempre use **subscription scope** com `--mode Complete` para evitar recursos órfãos.
* Teste sempre com `what-if` antes de criar recursos em produção.

---

## 📝 Checklist antes do deploy

Antes de rodar o deploy, verifique:

* [ ] Gerar chave SSH pública (`~/.ssh/id_rsa.pub`)
* [ ] Fazer login no Azure
* [ ] Selecionar a subscription correta
* [ ] Instalar/Verificar Bicep
* [ ] Validar template (`az deployment sub validate`)
* [ ] Testar `what-if` para revisão de mudanças
* [ ] Confirmar parâmetros no deploy (`sshPublicKey`, `adminUsername`)
* [ ] Deploy com `--mode Complete`
* [ ] Verificar outputs da implantação (`resourceGroupName`, `resourceGroupLocation`, `resourceGroupTags`)
* [ ] Remover recursos obsoletos, se necessário (`az group delete`)

---

## 📌 Referências

* [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/overview)
* [Deploy with Azure CLI](https://learn.microsoft.com/azure/azure-resource-manager/templates/deploy-cli)
* [SSH Key Login for Linux VMs](https://learn.microsoft.com/azure/virtual-machines/linux/mac-create-ssh-keys)

---

## ✅ Resumo de comandos (`main.azcli`)

```bash
# Login
az login --use-device-code

# Set subscription
az account set --subscription '<SUBSCRIPTION_ID>'

# Install Bicep
az bicep install --version v0.39.26

# Check Bicep version
az bicep version

# Build template (optional)
az bicep build --file main.bicep --outfile main.arm.json

# Decompile template (optional)
az bicep decompile --file main.arm.json --force

# Dry-run
az deployment sub what-if --location eastus2 --template-file main.bicep

# Validate template
az deployment sub validate --location eastus2 --template-file main.bicep

# Deploy (always use --mode Complete for subscription scope)
az deployment sub create \
  --location eastus2 \
  --template-file main.bicep \
  --parameters sshPublicKey="$(cat ~/.ssh/id_rsa.pub)" \
  --mode Complete

# Get outputs
az deployment sub show \
  --name main \
  --query properties.outputs.resourceGroupName.value -o tsv

# Delete example RG
az group delete --name "RG-23DF1793-A23D-5476-863F-3E07B3550827" --yes --no-wait
```

