resource "aws_instance" "first-ec2" {
  count         = 0
  ami           = "ami-00fa32593b478ad6e"
  instance_type = "t2.micro"
  tags = {
    Name = "testing"
  }
}
# Creating VPC

resource "aws_vpc" "main" {
  cidr_block = "20.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# Creating subnets

resource "aws_subnet" "public" {
  count             = 1
  vpc_id            = aws_vpc.main.id
  cidr_block        = "20.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private" {
  count             = 1
  vpc_id     = aws_vpc.main.id
  cidr_block = "20.0.2.0/24"

  tags = {
    Name = "private-subnet"
  }
}

# Creating Internet gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-gateway"
  }
}

# Creating route table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Route table associate

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Creating Security group

resource "aws_security_group" "allow_ssh" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

# Creating Public and private instance

resource "aws_instance" "public_instance" {
  count             = 1
  ami           = "ami-00fa32593b478ad6e"  # Update with a valid AMI ID for your region
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.allow_ssh.name]
  associate_public_ip_address = true
  key_name      = "Jenkins_key"

  tags = {
    Name = "public-instance"
  }
}

resource "aws_instance" "private_instance" {
  count             = 1
  ami           = "ami-00fa32593b478ad6e"  # Update with a valid AMI ID for your region
  instance_type = "t2.micro"
  key_name      = "Jenkins_key"
  subnet_id     = aws_subnet.private.id
  security_groups = [aws_security_group.allow_ssh.name]

  tags = {
    Name = "private-instance"
  }
}
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "public_instance_id" {
  value = aws_instance.public_instance.id
}

output "private_instance_id" {
  value = aws_instance.private_instance.id
}
output "public_instance_ip" {
  value = aws_instance.public.*.public_ip
}
