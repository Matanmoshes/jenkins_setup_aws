
# Jenkins Build Agent Setup on AWS

## Project Overview

This project automates the deployment of a Jenkins CI/CD environment on AWS using Terraform. It provisions a Jenkins master server and Docker-ready build agent nodes, allowing Jenkins jobs to be executed in Docker containers for better isolation and consistency. The infrastructure includes EC2 instances for the Jenkins master and agents, an Elastic File System (EFS) for shared storage, and pre-configured software (Docker, Java, Maven, Python, etc.) on the agents for running a wide range of build tasks.

> **Note:**  
> The setup of the Jenkins master was done manually on the machine and is not part of the automated Terraform process.  
> You can find the installation script I created for the Jenkins setup at the following link:  
> [Jenkins and Tomcat Installation Script](https://github.com/Matanmoshes/Knowledge-Base/blob/main/Jenkins/Jenkins%20Installation/install_tomcat_jenkins.sh.md).

---

## Prerequisite:


---

### Purpose

The goal of this project is to:
- Automate the setup of Jenkins master and Docker-based build agents using Terraform.
- Ensure that all Jenkins build agents are Docker-ready to run containerized build jobs.
- Use AWS EFS to provide shared storage between the Jenkins master and agents for build artifacts.
- Simplify Continuous Integration (CI) and Continuous Deployment (CD) processes by leveraging Jenkins pipelines.

---

## Key Components

### 1. **Infrastructure**
   - **Jenkins Master**: EC2 instance running the Jenkins master, accessible via a web interface on port 8080.
   - **Jenkins Agents**: Two EC2 instances acting as build agents, pre-configured to run Docker containers.
   - **Elastic File System (EFS)**: A shared file system mounted on both the Jenkins master and agent instances, enabling consistent access to build artifacts across nodes.
   - **Security Groups**: AWS security groups are set up to allow SSH and HTTP access to the Jenkins master and agents.


----

### 2. **Required Jenkins Plugins**
To fully enable Jenkins functionality and Docker support, the following plugins should be installed via the Jenkins GUI:

- **Docker Pipeline Plugin**: To run Jenkins jobs inside Docker containers on agents.
- **Blue Ocean Plugin**: A modern UI for managing and visualizing Jenkins pipelines.
- **Git Plugin**: To interact with Git repositories for source control.
- **Credentials Binding Plugin**: For securely handling sensitive credentials (e.g., AWS keys).
- **Pipeline: AWS Steps Plugin**: For interacting with AWS resources from within Jenkins pipelines.
- **Terraform Plugin**: To run Terraform commands directly from Jenkins pipelines for Infrastructure as Code (IaC).

---

## How to Run the Setup

### 1. **Pre-requisites**
   - **AWS CLI**: Ensure the AWS CLI is installed and configured with your credentials.
   - **Terraform**: Download and install [Terraform](https://www.terraform.io/downloads.html).
   - **AWS Key Pair**: Ensure an AWS Key Pair exists for SSH access to the EC2 instances (e.g., `jenkins-21-09-24.pem`).

---

### 2. **Clone the Repository**
   Clone the project repository to your local machine:
   ```bash
   git clone https://github.com/your-repo/jenkins-docker-aws-setup.git
   cd jenkins-docker-aws-setup
   ```

---

### 3. **Edit Terraform Variables**
   Modify the `variables.tf` file to suit your AWS environment:
   - Update the **AMI ID**, **instance types**, and **key name** to match your setup.

   Example:
   ```hcl
   variable "key_name" {
     default = "jenkins-21-09-24"  # AWS key pair name
   }
   ```

---

### 4. **Run Terraform**
   - Initialize the working directory:
     ```bash
     terraform init
     ```
   - Review the changes:
     ```bash
     terraform plan
     ```
   - Apply the Terraform configuration:
     ```bash
     terraform apply
     ```

   Confirm by typing `yes` when prompted. Terraform will provision the Jenkins master and agents, configure security groups, and set up EFS.

---

### 5. **Access Jenkins**
   - After provisioning, you can SSH into the Jenkins master using the AWS key pair:
     ```bash
     ssh -i /path/to/jenkins-21-09-24.pem ubuntu@<jenkins-master-public-ip>
     ```
   - Access the Jenkins UI by navigating to `http://<jenkins-master-public-ip>:8080` in your web browser.


---

### 6. **Install Required Jenkins Plugins**
   - Navigate to **Manage Jenkins** > **Manage Plugins**.
   - Install the required plugins from the list above, especially **Docker Pipeline Plugin** and **Git Plugin**.

---

### 7. **Add the Agent Node in Jenkins Master**:
Once your EC2 instance (agent) is ready, follow these steps to add it as a node in Jenkins:

#### Step 1: Access Jenkins Master
Open your Jenkins master web interface (http://<jenkins-master-public-ip>:8080).
Log in with your credentials.

#### Step 2: Add a New Node
On the Jenkins dashboard, go to Manage Jenkins > Manage Nodes and Clouds.
Click on New Node.
Enter a Node Name (e.g., docker-agent-1).
Choose Permanent Agent and click OK.

#### Step 3: Configure the Node
Description: (Optional) Add a description like "Docker-enabled Jenkins agent".
Remote Root Directory: Set this to /home/jenkins (the home directory of the jenkins user on the agent server).
Labels: Add a label (e.g., docker-agent), which can be used to assign jobs to this agent.
Usage: Set this to "Use this node as much as possible".
Launch method: Choose "Launch agent via SSH".

#### step 4: Configure SSH Credentials for Agent Connection
To allow the Jenkins master to connect to the agent via SSH:

- Host: Enter the Public IP of the agent EC2 instance (you can find this in your AWS EC2 dashboard).
- Credentials:
Click Add > Jenkins to open the credentials dialog.
- Fill out the SSH Credentials:
- Kind: Select SSH Username with private key.
- Scope: Set to Global (Jenkins, nodes, items, all child items, etc.).
- Username: Set this to jenkins (the user you created on the agent server).
- Private Key: Choose Enter directly, and copy-paste the contents of your .pem file (the key used to SSH into your EC2 instance).
- Passphrase: Leave blank (unless the key is encrypted).
- Description: Add a description like SSH key for Jenkins agent node.
- Click Add or Save.
- Host Key Verification Strategy:
Select "Known hosts file Verification Strategy" or change it to "Manually trusted key verification strategy" if you want to automatically trust the agent.
- Click Save to store the agent configuration.


---

### 8. **Verify Docker on Agents**
   Ensure that Docker is running on the Jenkins agents by SSH'ing into one of the agents:
   ```bash
   ssh -i /path/to/jenkins-21-09-24.pem ubuntu@<jenkins-agent-public-ip>
   docker run hello-world
   ```

   This will confirm that Docker is working on the agent nodes, allowing Jenkins jobs to run in containers.

---

### 9. **Create Jenkins Pipeline**
   Create a Jenkins pipeline to run build tasks inside Docker containers. Below is a sample `Jenkinsfile` to use:

   ```groovy
   pipeline {
       agent {
           label 'docker-agent'  // Make sure the agent label matches your node label
       }
       stages {
           stage('Build') {
               steps {
                   script {
                       docker.image('maven:3.8.1-jdk-11').inside {
                           sh 'mvn clean install'
                       }
                   }
               }
           }
           stage('Test') {
               steps {
                   script {
                       docker.image('python:3.8').inside {
                           sh 'python3 -m unittest discover'
                       }
                   }
               }
           }
       }
   }
   ```

---

## Future Enhancements

- **Auto-Scaling Jenkins Agents**: Implement auto-scaling to automatically scale Jenkins agents based on workload.
- **SSL/TLS**: Secure Jenkins with SSL/TLS for HTTPS access.
- **Monitoring**: Add monitoring tools such as CloudWatch or Prometheus to monitor Jenkins jobs and infrastructure.

---

## Troubleshoot

If it looks like the Tomcat service is running properly on your Jenkins Agent 2 (example: `10.0.1.103`), but you are facing a timeout issue when trying to access it via the public IP (example: `54.146.198.126`). This issue is likely related to network configurations, specifically security group settings or firewall rules.

### Here are the steps to troubleshoot and resolve the issue:

### 1. **Check Security Group Rules**
Ensure that the security group attached to your Jenkins agent allows inbound traffic on the **Tomcat default port (8080)**. Follow these steps:

1. **Go to AWS Console**:
   - Navigate to **EC2** > **Instances** and find your instance (`Jenkins Agent 2`).
   - Locate the **Security Groups** associated with this instance.

2. **Edit Inbound Rules**:
   - In the security group, edit the **Inbound Rules** to allow traffic on **port 8080** for **TCP**.
   - You can either open it to the world (for testing purposes) or restrict it to your specific IP:
     - **Type**: Custom TCP Rule
     - **Protocol**: TCP
     - **Port Range**: 8080
     - **Source**: `0.0.0.0/0` (for open access) or your specific IP.

3. **Save the changes** and try accessing the Tomcat server again.

### 2. **Check Firewall (UFW) on the Instance**
If UFW (Uncomplicated Firewall) is enabled on the instance, ensure that port 8080 is allowed:

1. **SSH into the instance**:
   ```bash
   ssh -i /path/to/your-key.pem ubuntu@54.146.198.126
   ```

2. **Check UFW status**:
   ```bash
   sudo ufw status
   ```

3. **Allow port 8080** if not already allowed:
   ```bash
   sudo ufw allow 8080
   sudo ufw reload
   ```

### 3. **Ensure Tomcat Is Listening on Port 8080**
Verify that Tomcat is correctly listening on port 8080:

1. **Run this command** on the Jenkins agent:
   ```bash
   sudo netstat -tulnp | grep 8080
   ```

2. You should see Tomcat listening on `0.0.0.0:8080` or `::0:8080`. If it’s not listening on the public interface, check the Tomcat configuration.

   - Edit the **`server.xml`** file located in `/opt/tomcat/conf/server.xml` and ensure the **Connector** is configured to listen on the correct port:
     ```xml
     <Connector port="8080" protocol="HTTP/1.1"
                connectionTimeout="20000"
                redirectPort="8443" 
                address="0.0.0.0"/>  <!-- Ensure this address is set to 0.0.0.0 for public access -->
     ```

3. **Restart Tomcat** after making any changes:
   ```bash
   sudo systemctl restart tomcat
   ```

### 4. **Check Local Firewall/Proxy Settings**
Make sure your local network or machine isn't blocking access to port 8080. You can try accessing Tomcat from a different network or device to rule out local issues.

### 5. **Test Access Again**
Once you've made the necessary changes, try accessing Tomcat again via `http://54.146.198.126:8080`.
