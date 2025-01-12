#=============== AMI =================#

data "aws_ami" "ubuntu-ami" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}

#================= EC2 =================#

# Jump-server
resource "aws_instance" "Jump-server" {
  ami                         = data.aws_ami.ubuntu-ami.id
  instance_type               = "t2.small"
  key_name                    = "DevOps"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg.id]
  user_data                   = filebase64("./script/jump.sh")

  tags = {
    Name = "Nexus"
  }
}
/*
# Jenkins
resource "aws_instance" "Jenkins" {
  ami                         = data.aws_ami.ubuntu-ami.id
  instance_type               = "t2.medium"
  key_name                    = "DevOps"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg.id]
  user_data                   = filebase64("./script/jenkins.sh")

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    delete_on_termination = true
    encrypted             = false
  }

  tags = {
    Name = "Jenkins"
  }
}

# SonarQube
resource "aws_instance" "sonarqube" {
  ami                         = data.aws_ami.ubuntu-ami.id
  instance_type               = "t2.medium"
  key_name                    = "DevOps"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg.id]
  user_data                   = filebase64("./script/sonarqube.sh")

  tags = {
    Name = "SonarQube"
  }
}
*/
#=============== security groups ==============#

resource "aws_security_group" "sg" {
  name   = "CI-SG"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "CI-SG"
  }

}

