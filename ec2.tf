#resource "aws_key_pair" "webserver-key" {
#    key_name   = "jenkins-key"
#    public_key = file("~/.ssh/id_rsa.pub")
#}

resource "aws_instance" "jenkins_master" {
    ami           = var.ami
    instance_type = var.instance_type
    subnet_id     = aws_subnet.public.id
    key_name      = var.key_name
    vpc_security_group_ids = [aws_security_group.jenkinsSG.id]

    user_data = <<-EOF
        #!/bin/bash
        sudo apt-get update -y
        sudo apt-get install -y java-11-openjdk-devel python3 maven git docker amazon-efs-utils
        sudo systemctl start docker
        sudo systemctl enable docker
        
        # Mount EFS
        mkdir /mnt/efs
        sudo mount -t efs ${aws_efs_file_system.jenkins_efs.id}:/ /mnt/efs
    EOF


    tags = {
        Name = "Jenkins Master"
    }
}

resource "aws_instance" "jenkins_agent1" {
    ami           = var.ami
    instance_type = var.instance_type
    subnet_id     = aws_subnet.public.id
    key_name      = var.key_name
    vpc_security_group_ids = [aws_security_group.jenkinsSG.id]

    user_data = <<-EOF
        #!/bin/bash
        sudo apt update -y
        sudo apt install openjdk-11-jdk -y
        sudo useradd -m -s /bin/bash jenkins
        echo "jenkins:password" | sudo chpasswd
        sudo usermod -aG sudo jenkins
        sudo -u jenkins ssh-keygen -t rsa -b 4096 -f /home/jenkins/.ssh/id_rsa -N ""
        sudo chmod 600 /home/jenkins/.ssh/id_rsa
        sudo apt install git -y
        sudo apt install maven -y
        sudo apt install docker.io -y
        sudo usermod -aG docker jenkins
        sudo apt install python3 -y
        sudo apt install python3-pip -y
        sudo systemctl enable ssh
        sudo systemctl start ssh
        sudo ufw allow OpenSSH
        sudo ufw --force enable
        sudo reboot
        
        # Mount EFS
        mkdir /mnt/efs
        sudo mount -t efs ${aws_efs_file_system.jenkins_efs.id}:/ /mnt/efs
    EOF

    tags = {
        Name = "Jenkins Agent 1"
    }
}

resource "aws_instance" "jenkins_agent2" {
    ami           = var.ami
    instance_type = var.instance_type
    subnet_id     = aws_subnet.public.id
    key_name      = var.key_name
    vpc_security_group_ids = [aws_security_group.jenkinsSG.id]

    user_data = <<-EOF
        #!/bin/bash
        sudo apt update -y
        sudo apt install openjdk-11-jdk -y
        sudo useradd -m -s /bin/bash jenkins
        echo "jenkins:password" | sudo chpasswd
        sudo usermod -aG sudo jenkins
        sudo -u jenkins ssh-keygen -t rsa -b 4096 -f /home/jenkins/.ssh/id_rsa -N ""
        sudo chmod 600 /home/jenkins/.ssh/id_rsa
        sudo apt install git -y
        sudo apt install maven -y
        sudo apt install docker.io -y
        sudo usermod -aG docker jenkins
        sudo apt install python3 -y
        sudo apt install python3-pip -y
        sudo systemctl enable ssh
        sudo systemctl start ssh
        sudo ufw allow OpenSSH
        sudo ufw --force enable
        sudo reboot
        
        # Mount EFS
        # mkdir /mnt/efs
        # sudo mount -t efs ${aws_efs_file_system.jenkins_efs.id}:/ /mnt/efs
    EOF

    tags = {
        Name = "Jenkins Agent 2"
    }
}
