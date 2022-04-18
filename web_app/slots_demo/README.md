# Web App Slot Swap Demo

## Get Started

### Deploy the infrastructure and web app

```bash
cd deploy
terraform init
terraform apply -auto-approve
```

To view the deployment go to the Urls of production and stage environments, and see the difference.

### Swaps stage and production slots

```bash
cd ../swap
terraform init
terraform apply -auto-approve
```

Again on the Urls of production and stage environments, verify the stage and production environments have been swapped.
