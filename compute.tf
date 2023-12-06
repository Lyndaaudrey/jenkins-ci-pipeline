# Jenkin server ami
#
data "aws_ami" "ubuntu_server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}




# Création key pair

resource "aws_key_pair" "project_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)

}


#Création server jenkins

 resource "aws_instance" "jenkins_server" {
  ami                    = data.aws_ami.ubuntu_server_ami.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.project_auth.id
  vpc_security_group_ids = [aws_security_group.instances_sg.id]
  subnet_id              = aws_subnet.project_public_subnet.id
  user_data              = file("./scripts/jenkins-setup.sh") 

  root_block_device {
    volume_size = var.main_vol_size
  }

  tags = {
    Name = "Jenkins-server"
  }

} 

#Associatio server jenkins à une adresse ip elastic

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.jenkins_server.id
  allocation_id = var.jenkins_ip
} 

# Création server nexus

   resource "aws_instance" "nexus_server" {
  ami                    = var.amazon_linux_ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.project_auth.id
  vpc_security_group_ids = [aws_security_group.instances_sg.id]
  subnet_id              = aws_subnet.project_public_subnet.id
  user_data              = file("./scripts/nexus-setup.sh") 

  root_block_device {
    volume_size = var.main_vol_size
  }

  tags = {
    Name = "nexus-server"
  }

}  

 # Création serveur sonarqube

  resource "aws_instance" "sonar_server" {
  ami                    = data.aws_ami.ubuntu_server_ami.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.project_auth.id
  vpc_security_group_ids = [aws_security_group.instances_sg.id]
  subnet_id              = aws_subnet.project_public_subnet.id
  user_data              = file("./scripts/sonar-setup.sh") 

  root_block_device {
    volume_size = var.main_vol_size
  }

  tags = {
    Name = "sonar-server"
  }

}   






