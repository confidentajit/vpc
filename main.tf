# Key- pair Created
provider "tls" {}
resource "tls_private_key" "ajit" {
  algorithm = "RSA"
  rsa_bits = "2048"
  # tags       = local.tags
}
resource "aws_key_pair" "ajit" {
  key_name   = "${var.name}-key"
  public_key = tls_private_key.ajit.public_key_openssh
}
resource "aws_vpc" "myvpc2" {
  cidr_block = var.cidr
}
# Security
resource "aws_security_group" "test-sg" {
  name = "${var.name}-sg"
  description = " SG using Dynamic-Block"
  vpc_id = aws_vpc.myvpc2.id
  dynamic "ingress" {
         for_each = [80,22]
    iterator = port
    content {
      description = "TLS from VPC"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}  
# Network Blocks
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.myvpc2.id
  tags = {
      Name = var.name
    }
  }



resource "aws_route" "igw-add-route-pub" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.ig.id
  
}
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.myvpc2.id
  tags = {
    name= "${var.name}-igw"
  }

}
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.myvpc2.id
  count = length(var.subnet_cidr)
  cidr_block = element(var.subnet_cidr,count.index)
  availability_zone = element(var.azs,count.index)
  map_public_ip_on_launch = "true"
  tags = {
    Name = element(var.subnet-name,count.index)
  }
}

resource "aws_instance" "Test-VM" {
  count=length(var.instancename)
  ami = data.aws_ami.linux.id
  instance_type = var.instance_type
  availability_zone = element(var.availability_zone,count.index)
  key_name = aws_key_pair.ajit.id
  subnet_id = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.test-sg.id]
  tags = {
    name= "${var.name}-VM"
    Name  = "Terraform-${count.index + 1}"
  }
  
}







data "aws_ami" "linux" {
   most_recent = true
   owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

    









