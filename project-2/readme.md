# To setup the infra
```bash
terraform apply -var-file=terraform.tfvars -auto-approve

# Ping the instances
ansible public_servers -i inventory/hosts.yaml -m ping
# If the controller node for ansible is in the same VPC, you can use the private_servers here as well, which is considered a better and secure approach.
```