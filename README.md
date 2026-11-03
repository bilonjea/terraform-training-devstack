# Terraform – DevStack on AWS

Creates a dedicated Ubuntu 24.04 EC2 host in `us-east-2` and runs the official DevStack `stack.sh` from cloud-init.

## Important sizing warning

`m7i-flex.large` has 2 vCPU and 8 GiB RAM. This is constrained for an all-in-one OpenStack environment. OpenStack-related lab guidance for heavier deployments commonly recommends 4 CPU cores, 16 GB RAM and 80 GB storage. Installation may be slow or fail under memory pressure. The project keeps your requested size; consider `m7i-flex.xlarge` (4 vCPU / 16 GiB) if quota and budget permit.

`LIBVIRT_TYPE=qemu` is set to avoid relying on nested KVM virtualization being available inside EC2. Guest VMs will be slower.

## Prerequisites

- Terraform >= 1.9
- AWS CLI credentials with permission to create EC2, security groups and key pairs
- A default VPC and at least one subnet in `us-east-2`
- SSH public key
- Your public IPv4 address

## Configure and deploy

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`. Replace `admin_cidr` with your public IP in `/32` form. Ensure `ssh_public_key_path` points to your public key.

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

`terraform apply` only waits for EC2 creation. DevStack installation continues asynchronously in cloud-init.

## Retrieve access details

```bash
terraform output
terraform output -raw public_ip
terraform output -raw devstack_admin_password
```

Horizon: `http://PUBLIC_IP/`, user `admin`.

The password is marked sensitive but is stored in Terraform state and passed through EC2 user data. Protect the state and limit access to it.

## Follow installation

```bash
ssh -i ~/.ssh/id_ed25519 ubuntu@$(terraform output -raw public_ip)
sudo cloud-init status --long
sudo tail -f /var/log/devstack-bootstrap.log
sudo tail -f /opt/stack/logs/stack.sh.log
free -h
df -h
```

OpenStack CLI:

```bash
sudo -iu stack
cd /opt/stack/devstack
source openrc admin
openstack token issue
openstack service list
```

## Security and networking

The security group restricts SSH, HTTP and HTTPS to `admin_cidr`. Do not expose SSH or Horizon to `0.0.0.0/0`.

This is a DevStack development environment, not a production OpenStack deployment. Neutron networks and floating IPs are nested behind AWS networking; successful Horizon access does not guarantee that nested VMs are reachable from the Internet.

## Destroy

```bash
terraform destroy
```

Deletes the EC2 host, security group and key pair created by this project.
