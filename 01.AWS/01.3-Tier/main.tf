provider "aws" {
  region = "ap-northeast-2"
}

resource "aws_vpc" "terraform_dev_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "terraform-dev-vpc"
  }
}

resource "aws_internet_gateway" "terraform_dev_igw" {
  vpc_id = aws_vpc.terraform_dev_vpc.id
  tags = {
    Name = "terraform-dev-igw"
  }
}

resource "aws_subnet" "web_dev_pub1" {
  vpc_id            = aws_vpc.terraform_dev_vpc.id
  cidr_block        = var.web_dev_pub1_cidr
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "web-dev-pub1"
  }
}

resource "aws_subnet" "web_dev_pub2" {
  vpc_id            = aws_vpc.terraform_dev_vpc.id
  cidr_block        = var.web_dev_pub2_cidr
  availability_zone = "ap-northeast-2b"
  map_public_ip_on_launch = true
  tags = {
    Name = "web-dev-pub2"
  }
}

resource "aws_subnet" "was_dev_pri1" {
  vpc_id            = aws_vpc.terraform_dev_vpc.id
  cidr_block        = var.was_dev_pri1_cidr
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "was-dev-pri1"
  }
}

resource "aws_subnet" "was_dev_pri2" {
  vpc_id            = aws_vpc.terraform_dev_vpc.id
  cidr_block        = var.was_dev_pri2_cidr
  availability_zone = "ap-northeast-2b"
  tags = {
    Name = "was-dev-pri2"
  }
}

resource "aws_subnet" "db_dev_pri1" {
  vpc_id            = aws_vpc.terraform_dev_vpc.id
  cidr_block        = var.db_dev_pri1_cidr
  availability_zone = "ap-northeast-2a"
  tags = {
    Name = "db-dev-pri1"
  }
}

resource "aws_subnet" "db_dev_pri2" {
  vpc_id            = aws_vpc.terraform_dev_vpc.id
  cidr_block        = var.db_dev_pri2_cidr
  availability_zone = "ap-northeast-2b"
  tags = {
    Name = "db-dev-pri2"
  }
}

resource "aws_nat_gateway" "terraform_dev_nat" {
  allocation_id = aws_eip.terraform_dev_nat.id
  subnet_id     = aws_subnet.web_dev_pub1.id
  tags = {
    Name = "terraform-dev-nat"
  }
}

resource "aws_eip" "terraform_dev_nat" {
  domain = "vpc"
}

resource "aws_route_table" "terraform_dev_pub_rtb" {
  vpc_id = aws_vpc.terraform_dev_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_dev_igw.id
  }
  tags = {
    Name = "terraform-dev-pub-rtb"
  }
}

resource "aws_route_table" "terraform_dev_pri_rtb" {
  vpc_id = aws_vpc.terraform_dev_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terraform_dev_nat.id
  }
  tags = {
    Name = "terraform-dev-pri-rtb"
  }
}

resource "aws_route_table_association" "pub1_rtb_association" {
  subnet_id      = aws_subnet.web_dev_pub1.id
  route_table_id = aws_route_table.terraform_dev_pub_rtb.id
}

resource "aws_route_table_association" "pub2_rtb_association" {
  subnet_id      = aws_subnet.web_dev_pub2.id
  route_table_id = aws_route_table.terraform_dev_pub_rtb.id
}

resource "aws_route_table_association" "pri1_rtb_association" {
  subnet_id      = aws_subnet.was_dev_pri1.id
  route_table_id = aws_route_table.terraform_dev_pri_rtb.id
}

resource "aws_route_table_association" "pri2_rtb_association" {
  subnet_id      = aws_subnet.was_dev_pri2.id
  route_table_id = aws_route_table.terraform_dev_pri_rtb.id
}

resource "aws_route_table_association" "db1_rtb_association" {
  subnet_id      = aws_subnet.db_dev_pri1.id
  route_table_id = aws_route_table.terraform_dev_pri_rtb.id
}

resource "aws_route_table_association" "db2_rtb_association" {
  subnet_id      = aws_subnet.db_dev_pri2.id
  route_table_id = aws_route_table.terraform_dev_pri_rtb.id
}

resource "aws_security_group" "web_dev_sg" {
  vpc_id = aws_vpc.terraform_dev_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "web-dev-sg"
  }
}

resource "aws_security_group" "was_dev_sg" {
  vpc_id = aws_vpc.terraform_dev_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    security_groups = [aws_security_group.web_dev_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "was-dev-sg"
  }
}

resource "aws_security_group" "db_dev_sg" {
  vpc_id = aws_vpc.terraform_dev_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    security_groups = [aws_security_group.was_dev_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-dev-sg"
  }
}

resource "aws_instance" "web1_dev" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.web_dev_pub1.id
  security_groups = [aws_security_group.web_dev_sg.id]
  key_name      = var.key_name

  tags = {
    Name = "web1-dev"
  }
}

resource "aws_instance" "was1_dev" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.was_dev_pri1.id
  security_groups = [aws_security_group.was_dev_sg.id]
  key_name      = var.key_name

  tags = {
    Name = "was1-dev"
  }
}

resource "aws_instance" "db1_dev" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.db_dev_pri1.id
  security_groups = [aws_security_group.db_dev_sg.id]
  key_name      = var.key_name

  tags = {
    Name = "db1-dev"
  }
}
