variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "project_name" {
  type    = string
  default = "terraform-devstack"
}

variable "environment" {
  type    = string
  default = "training"
}

variable "instance_type" {
  type    = string
  default = "m7i-flex.large"
}

variable "root_volume_size" {
  type    = number
  default = 100
}

variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

variable "admin_cidr" {
  description = "Your public IPv4 in CIDR form, e.g. 203.0.113.10/32"
  type        = string
}

variable "key_pair_name" {
  type    = string
  default = "terraform-devstack-key"
}

variable "devstack_repo_url" {
  type    = string
  default = "https://opendev.org/openstack/devstack"
}

variable "devstack_branch" {
  description = "Git branch or stable branch. master follows current development."
  type        = string
  default     = "master"
}
