# End-to-End Deployment of a Netflix Clone on EKS with Jenkins and Argo CD

# Project Structure:
## Phase 1: Infrastructure setup with Terraform
* [Setup Jump, SonarQube, and Jenkins server](#servers)
* [EKS cluster](#eks-cluster)
## Phase 2: Configure Jenkins and Build the CI pipeline
* Install the required plugins and configure tools
* Configure credentials (GitHub, DockerHub, gmail, sonarqube)
* Configure Jenkins with SonarQube server
* Configure SMTP server on Jenkins for sending email notfications
* Build the CI pipeline
## Phase 3: Configure EKS Cluster and Build the CD pipeline
* Install Helm
* Install Argo CD
* Install AWS LoadBalancer Controller
* Install ExternalDNS
## Phase 4: Setup and Configure Prometheus and Grafana
* Install Prometheus-stack 
## Phase 1: Infrastructure setup with Terraform
## Servers
First, We need to provision a jump server where can execute all kubernetes related commands. Then, provision Jenkins server for CI pipeline and SonarQube server for static code analysis. To do so, I have created a Terraform code that provisions all these three servers. The Terraform code will install the AWS cli, kubectl, and eksctl for the jump server, JAVA and jenkins for the Jenkins server, and will also install sonarqube docker image for the SonarQube server. To run the terraform code, navigate to `Terraform/Jenkins-SonarQube-Jump-Server` folder, and then run the follwing commands:
```
terraform init
terraform apply --auto-approve
```
## EKS cluster
To provisiong an EKS cluster, navigate to `Terraform/EKS` folder and run the following commands:
```
terraform init
terraform apply --auto-approve
```