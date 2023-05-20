# встановлення aws
provider "aws" {
  access_key = "ключ_доступу_AWS"
  secret_access_key = "секретний_ключ_AWS"
  region = "us-west-2"
}

# створення VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# створення підмереж
resource "aws_subnet" "subnet1" {
vpc_id = aws_vpc.my_vpc.id
cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "subnet2" {
vpc_id = aws_vpc.my_vpc.id
cidr_block = "10.0.2.0/24"
}

# створення групи безпеки
resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  # дозвіл доступу до порту 22 для SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # відкриття доступу до портів Prometheus, Node Exporter та Cadvizor Exporter
  # Prometheus
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Node Exporter
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Cadvizor Exporter
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# створення інстансів
resource "aws_instance" "instance1" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  user_data = <<-EOF
  #!/bin/bash

    # встановлення Docker
    sudo apt-get update
    sudo apt-get install -y docker.io

    # Prometheus, Node Exporter, Cadvizor Exporter
    sudo docker run -d --name prometheus -p 9090:9090 prom/prometheus
    sudo docker run -d --name node-exporter -p 9100:9100 prom/node-exporter
    sudo docker run -d --name cadvizor-exporter -p 8080:8080 google/cadvisor
  EOF

  tags = {
    Name = "Instance1"
  }
}

resource "aws_instance" "instance2" {
  ami           = "ami-0c94855ba95c71c99"
  instance_type = "t2.micro"
  user_data = <<-EOF
  #!/bin/bash

    sudo apt-get update
    sudo apt-get install -y docker.io
    
    # Node Exporter, Cadvizor Exporter
    sudo docker run -d --name node-exporter -p 9100:9100 prom/node-exporter
    sudo docker run -d --name cadvizor-exporter -p 8080:8080 google/cadvisor
  EOF

  tags = {
    Name = "Instance2"
  }
}
