data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "node" {
  count = var.node_count

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.sg_id]
  key_name               = var.key_name

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  # cloud-init prepares the OS only. k3s is installed manually per the README runbook.
  user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail
    swapoff -a
    sed -i '/ swap / s/^/#/' /etc/fstab
    echo "vm.max_map_count=262144" >> /etc/sysctl.conf
    echo "fs.file-max=131072" >> /etc/sysctl.conf
    sysctl -p
    apt-get update -qq
    apt-get install -y -qq curl jq unzip
  EOF

  tags = {
    Name = "${var.project_name}-node-${count.index + 1}"
    Role = count.index == 0 ? "k3s-server" : "k3s-agent"
    Node = "node-${count.index + 1}"
  }
}

resource "aws_eip" "node" {
  count  = var.node_count
  domain = "vpc"

  instance = aws_instance.node[count.index].id

  tags = {
    Name = "${var.project_name}-node-${count.index + 1}"
  }
}
