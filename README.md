# End-to-End Deployment of a Netflix Clone on EKS with Jenkins and Argo CD

# Project Structure:
## Phase 1: Infrastructure setup with Terraform
* [Servers](#servers)
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
## servers
## EKS cluster