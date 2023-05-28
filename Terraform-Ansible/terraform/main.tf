provider "aws" {
  region = "eu-west-1"
}

################################################################################
# Supporting Resources
################################################################################
resource "aws_subnet" "subnet-main" {
  vpc_id     = aws_vpc.vpc-main.id
  cidr_block = "172.2.0.0/16"

  tags = {
    Name = "subnet-main"
  }
}

resource "aws_vpc" "vpc-main" {
  cidr_block = "172.2.0.0/16"

  tags = {
    Name = "vpc-main"
  }
}
################################################################################
# Local Variables
################################################################################
# locals {
#   region = "eu-west-1"
#   name   = "devops-practise"

#   instances = [
#     {
#       name      = "jenkins-server"
#       user_data = <<-EOT
#       #!/bin/bash
#       sudo yum update –y
#       sudo amazon-linux-extras install epel -y
#       sudo amazon-linux-extras install java-openjdk11 -y
#       sudo wget -O /etc/yum.repos.d/jenkins.repo \
#         https://pkg.jenkins.io/redhat-stable/jenkins.repo
#       sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
#       sudo yum upgrade -y 
#       sudo yum install git -y
#       sudo yum install jenkins -y
#       sudo sudo service jenkins start
#       echo "jenkins-server" > /etc/hostname && hostnamectl set-hostname "jenkins-server"
#       sudo sudo service jenkins restart
#       sudo yum install git -y
#       sudo mkdir /opt/maven
#       sudo wget -O /opt/maven/apache-maven-3.9.2-bin.tar.gz https://dlcdn.apache.org/maven/maven-3/3.9.2/binaries/apache-maven-3.9.2-bin.tar.gz
#       sudo tar -xvzf /opt/maven/apache-maven-3.9.2-bin.tar.gz -C /opt/maven
#       sudo mv /opt/maven/apache-maven-3.9.2 /opt/maven/apache-maven      
#       sudo rm /opt/maven/apache-maven-3.9.2-bin.tar.gz
#       existing_path=$(grep -oP '(?<=^PATH=).+' ~/.bash_profile)
#       echo "M2_HOME=/opt/maven/apache-maven" | sudo tee -a ~/.bash_profile >/dev/null
#       echo "M2=\$M2_HOME/bin" | sudo tee -a ~/.bash_profile >/dev/null
#       echo "JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.18.0.10-1.amzn2.0.1.x86_64" | sudo tee -a ~/.bash_profile >/dev/null
#       new_path="PATH=$PATH:$HOME/.local/bin:$HOME/bin:\$M2_HOME:\$M2:\$JAVA_HOME"
#       updated_path="\$PATH:$HOME/bin:$new_path"
#       sed -i "s#^PATH=.*#PATH=$updated_path#" ~/.bash_profile
#   EOT
#     },
#     {
#       name      = "docker-instance"
#       user_data = <<-EOT
#       #!/bin/bash
#       sudo yum update -y
#       sudo yum install -y docker
#       sudo service docker start
#       sudo usermod -aG docker $(whoami)
#       sudo chkconfig docker on
#       sudo useradd dockeradmin
#       sudo passwd dockeradmin
#       sudo usermod -aG docker dockeradmin
#       echo "docker-server" > /etc/hostname && hostnamectl set-hostname "docker-server"
#       EOT
#     }
#   ]

#   tags = {
#     for instance in local.instances :
#     instance.name => {
#       Name    = instance.name
#       Project = local.name
#     }
#   }
# }

################################################################################
# EC2 Module
################################################################################
# module "ec2_instances" {
#   source                      = "terraform-aws-modules/ec2-instance/aws"
#   count                       = length(local.instances)
#   name                        = local.instances[count.index].name
#   ami                         = "ami-04f7efe62f419d9f5"
#   instance_type               = "t2.micro"
#   subnet_id                   = aws_subnet.main.id
#   security_groups             = "jenkins-sg-2023"
#   associate_public_ip_address = true
#   key_name                    = "newInstance"
#   user_data_base64            = base64encode(local.instances[count.index].user_data)
#   user_data_replace_on_change = true
#   tags                        = local.tags[local.instances[count.index].name]
# }

resource "aws_instance" "ec2_instances" {
  # source                      = "terraform-aws-modules/ec2-instance/aws"
  # count                       = length(local.instances)
  # name                        = test-instance
  ami                           = "ami-04f7efe62f419d9f5"
  instance_type                 = "t2.micro"
  subnet_id                   = aws_subnet.subnet-main.id
  security_groups               = ["jenkins-sg-2023"]
  # associate_public_ip_address = true
  key_name                      = "newInstance"
  # user_data_base64            = base64encode(local.instances[count.index].user_data)
  # user_data_replace_on_change = true
  tags                          = {
     Name = "test-instance-type"
  }
}

################################################################################
# SG GROUP
################################################################################

#Create security group with firewall rules
resource "aws_security_group" "jenkins-sg-2023" {
  name        = "jenkins-sg-2023"
  description = "security group for jenkins"
  vpc_id      = aws_vpc.vpc-main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["172.2.0.0/16"]
  }

 # outbound from Jenkins server
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 tags = {
  Name = "jenkins-sg-2023"
 }
}