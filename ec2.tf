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
        sudo apt install git -y
        sudo apt install maven -y
        
        # Install Docker
        mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
          https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
          | tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        apt-get update -y
        apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        
        # Start Docker service and enable it on boot
        systemctl start docker
        systemctl enable docker
        
        # Add ubuntu user to the docker group
        usermod -aG docker ubuntu
        
        # Install Docker Compose (Standalone)
        curl -L "https://github.com/docker/compose/releases/download/v2.22.0/docker-compose-linux-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose

        sudo usermod -aG docker jenkins
        sudo apt install python3 -y
        sudo apt install python3-pip -y
        sudo systemctl enable ssh
        sudo systemctl start ssh
        sudo ufw allow OpenSSH
        sudo ufw --force enable
        sudo reboot
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
    EOF

    tags = {
        Name = "Jenkins Agent 2"
    }
}
