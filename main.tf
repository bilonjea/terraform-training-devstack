data "aws_ssm_parameter" "ubuntu_2404_ami" {
  name = "/aws/service/canonical/ubuntu/server/24.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

data "aws_vpc" "default" { default = true }

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "random_password" "admin" {
  length = 20
  special = false
}

resource "aws_key_pair" "devstack" {
  key_name = var.key_pair_name
  public_key = file(pathexpand(var.ssh_public_key_path))
}

resource "aws_security_group" "devstack" {
  name = "${var.project_name}-sg"
  description = "Restricted access to the DevStack host"
  vpc_id = data.aws_vpc.default.id

  ingress {
    description = "SSH from administrator"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.admin_cidr]
  }
  ingress {
    description = "Horizon HTTP from administrator"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [var.admin_cidr]
  }
  ingress {
    description = "Horizon HTTPS from administrator"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [var.admin_cidr]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "devstack" {
  ami = data.aws_ssm_parameter.ubuntu_2404_ami.value
  instance_type = var.instance_type
  key_name = aws_key_pair.devstack.key_name
  subnet_id = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.devstack.id]
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = var.root_volume_size
    encrypted = true
    delete_on_termination = true
  }

  user_data = templatefile("${path.module}/templates/devstack-user-data.sh.tftpl", {
    admin_password = random_password.admin.result
    repo_url = var.devstack_repo_url
    branch = var.devstack_branch
  })
  user_data_replace_on_change = true

  tags = { Name = "${var.project_name}-host" }
}
