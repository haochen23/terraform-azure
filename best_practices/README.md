# Some best practices of using Terraform

## Using Partial Configuration

Store your backend credentials in a file, e.g. `azure.conf`, add it in `.gitignore`. And pass its values during runtime.

```bash
terraform init -backend-config azure.conf
```

Or save your access key of the storage account to an env variable

```bash
export ARM_ACCESS_KEY=$(az keyvault secret show --name terraform-backend-key --vault-name myKeyVault --query value -o tsv)
```

If in a pipeline configuration, pass the blob credentials through environment variables, like:

```yaml
steps:
  - bash: |
      terraform -version
      terraform init \
        -backend-config="storage_account_name=$TF_STATE_BLOB_ACCOUNT_NAME" \
        -backend-config="container_name=$TF_STATE_BLOB_CONTAINER_NAME" \
        -backend-config="key=$TF_STATE_BLOB_FILE" \
        -backend-config="sas_token=$TF_STATE_BLOB_SAS_TOKEN"
    displayName: Terraform Init
    env:
      TF_STATE_BLOB_ACCOUNT_NAME: $(kv-tf-state-blob-account)
      TF_STATE_BLOB_CONTAINER_NAME: $(kv-tf-state-blob-container)
      TF_STATE_BLOB_FILE: $(kv-tf-state-blob-file)
      TF_STATE_BLOB_SAS_TOKEN: $(kv-tf-state-sas-token)
```

And of course, get all these secrets from a key vault. Plan it. It is safe to pass ARM client secrets using environment variables. And it's a recommended way if not using Key Vault Task.

```yaml
parameters:
  - name: extraFlags
    type: string
    default: ""

steps:
  - bash: terraform plan -var superadmins_aad_object_id=$AAD_SUPERADMINS_GROUP_ID ${{ parameters.extraFlags }}
    displayName: Terraform Plan
    env:
      ARM_SUBSCRIPTION_ID: $(kv-arm-subscription-id)
      ARM_CLIENT_ID: $(kv-arm-client-id)
      ARM_CLIENT_SECRET: $(kv-arm-client-secret)
      ARM_TENANT_ID: $(kv-arm-tenant-id)
      AZDO_ORG_SERVICE_URL: $(kv-azure-devops-org-url)
      AZDO_PERSONAL_ACCESS_TOKEN: $(kv-azure-devops-pat)
      AAD_SUPERADMINS_GROUP_ID: $(kv-aad-superadmins-group-id)
```

Terraform Apply

```yaml
- stage: cd_stage
  displayName: CD - Deployment
  jobs:
    - job: deploy
      displayName: Terraform Plan and Apply
      steps:
        - template: steps/debug-vars.yaml
        - template: steps/terraform-init.yaml
        - template: steps/terraform-plan.yaml
          parameters:
            extraFlags: "-out=deployment.tfplan"

        - bash: terraform apply -auto-approve deployment.tfplan
          displayName: Terraform Apply
          env:
            ARM_SUBSCRIPTION_ID: $(kv-arm-subscription-id)
            ARM_CLIENT_ID: $(kv-arm-client-id)
            ARM_CLIENT_SECRET: $(kv-arm-client-secret)
            ARM_TENANT_ID: $(kv-arm-tenant-id)
            AZDO_ORG_SERVICE_URL: $(kv-azure-devops-org-url)
            AZDO_PERSONAL_ACCESS_TOKEN: $(kv-azure-devops-pat)
```

## Create Custom Role for Terraform

Sometimes a contributor role may not be what you need. Owner Role is simply too powerful.
