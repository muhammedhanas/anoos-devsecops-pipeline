resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_cidr
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.project_name}-rt"
  }
}

resource "aws_route_table_association" "assoc" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "nodes" {
  name        = "${var.project_name}-nodes"
  description = "k3s node traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# SSH - restrict cidr_blocks to your own IP before applying
resource "aws_security_group_rule" "ssh" {
  type              = "ingress"
  description       = "SSH"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.admin_cidr]
  security_group_id = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "http" {
  type              = "ingress"
  description       = "HTTP"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "https" {
  type              = "ingress"
  description       = "HTTPS"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nodes.id
}

# Kubernetes API - restrict to admin CIDR
resource "aws_security_group_rule" "kube_api" {
  type              = "ingress"
  description       = "k3s API server"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = [var.admin_cidr]
  security_group_id = aws_security_group.nodes.id
}

# Node-to-node only traffic
resource "aws_security_group_rule" "flannel_udp" {
  type              = "ingress"
  description       = "flannel VXLAN"
  from_port         = 8472
  to_port           = 8472
  protocol          = "udp"
  self              = true
  security_group_id = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "flannel_tcp" {
  type              = "ingress"
  description       = "flannel TCP"
  from_port         = 8472
  to_port           = 8472
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "kubelet" {
  type              = "ingress"
  description       = "kubelet API"
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "etcd" {
  type              = "ingress"
  description       = "etcd peer and client"
  from_port         = 2379
  to_port           = 2380
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "nodeports" {
  type              = "ingress"
  description       = "NodePort services"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  description       = "All outbound"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nodes.id
}
