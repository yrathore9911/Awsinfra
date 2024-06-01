# Creating VPC

resource "aws_vpc" "main" {
  cidr_block = "20.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# Creating subnets

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "20.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "20.0.2.0/24"

  tags = {
    Name = "private-subnet"
  }
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

# Key pair for instance

resource "aws_key_pair" "newkey" {
  key_name   = "newkey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCW7eNB1eOHkMWvsr/iThbcdL3WgO9TdJuyyiJBt0mGj0lFnQx+zsVxF4IIbX9Xnj3OgwDbNJy2JD2NvH1rYqOXsuQPoj3KeZdkjny2suAj3VEwDtzcQlFTkJ21df/J9MZ8fErgUH3tHLb2tPtIA2tnF7mY7iomQfsBj2wFpwE1dLRqBzd5MNXdKQFZaUXv4HbdNJef1PvWDZej/nsZPClAnu8Dr2Nnw//T94UrDspPb1ErY14pj0yxzBIo4g00IeP9mZT4mIfOFQqD43HuSM297L6sDcO9JRgqpVts9GxWTGVmxTvpeFZ3ttejtcNa7i0jLT++JF+ygAZpIxveYANRepSfPhminqKYvXP67sz6yhGnhMZucKXj2Hd0lexcIPmE+hhfb0xam0yRwwMRxLtKPXbI8jdP3oh/ymwRJFU8Abv141fD6JGjKAmKpRkjItEDLuAA8MrPUlhvoN3wWZi5LQ1kaMkMhG2A78PyrS3ztkJNCOZ4TKdX2nN4s6Z2Jp8= yash@Linuxuser-01"
  }


# Creating Public instance

resource "aws_instance" "public_instance" {
  ami           = "ami-00beae93a2d981137"  # Update with a valid AMI ID for your region
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.allow_ssh.id]
  key_name      = "newkey"

  tags = {
    Name = "public-instance"
  }
}

# Creating Private instance

resource "aws_instance" "private_instance" {
  ami           = "ami-00beae93a2d981137"  # Update with a valid AMI ID for your region
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
  security_groups = [aws_security_group.allow_ssh.id]
  key_name      = "newkey"

  tags = {
    Name = "private-instance"
   }
}

# creating public ip

resource "aws_eip" "public_instance_ip" {
  instance = aws_instance.public_instance.id
  domain   = "vpc"
}

# creating another public ip for nat gateway

resource "aws_eip" "natgwip" {
  domain   = "vpc"
}

# creating nat gateway for private subnet machine

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgwip.id
  subnet_id     = aws_subnet.public.id
}

# Creating route table for nat gateway.


resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Route table associate for nat gateway

resource "aws_route_table_association" "private-asso" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private-rt.id
}