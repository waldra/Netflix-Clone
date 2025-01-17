# End-to-End Deployment of a Netflix Clone on EKS with Jenkins and Argo CD :rocket:
![DevSecOps](https://github.com/waldra/Netflix-Clone/blob/main/images/netflix-CICD.png)
![netflix-5](https://github.com/waldra/Netflix-Clone/blob/main/images/5.png)
![netflix-6](https://github.com/waldra/Netflix-Clone/blob/main/images/6.png)
# Project Structure:
## Phase 1: Infrastructure setup with Terraform
* [Setup Jump, SonarQube, and Jenkins server](#servers)
* [EKS cluster](#eks-cluster)
## Phase 2: Configure Jenkins and Build the CI pipeline
* [Install the required plugins and configure tools](#plugins)
* [Configure credentials (GitHub, DockerHub, gmail, sonarqube)](#credentials-configuration)
* [Configure Jenkins with SonarQube server](#sonarqube-configuration)
* [Configure SMTP server on Jenkins for sending email notfications](#smtp-configuration)
* [Generate API Key from TMDB](#tmdb-api-key)
## Phase 3: Configure EKS Cluster and Build the CD pipeline
* [Install Helm](#helm-installation)
* [Install Argo CD](#argocd-installation)
* [Install AWS LoadBalancer Controller](#aws-loadbalancer-controller)
* [Install ExternalDNS](#externaldns-installation)
## Phase 4: Setup and Configure Prometheus and Grafana
* [Install Prometheus-stack](#prometheus-installation) 
## Phase 1: Infrastructure setup with Terraform
## Servers
First, We need to provision a jump server where can execute all kubernetes related commands. Then, provision Jenkins server for CI pipeline and SonarQube server for static code analysis. To do so, I have created a Terraform code that provisions all these three servers. The Terraform code will install the AWS cli, kubectl, and eksctl on the jump server, JAVA and jenkins on the Jenkins server, and will also install sonarqube docker image on the SonarQube server. To run the terraform code, navigate to `Terraform/Jenkins-SonarQube-Jump-Server` folder, and then run the follwing commands:
```bash
terraform init
terraform plan
terraform apply --auto-approve
```
## EKS cluster
To provisiong an EKS cluster, navigate to `Terraform/EKS` folder and run the following commands:
```bash
terraform init
terraform plan
terraform apply --auto-approve
```
## Phase 2: Configure Jenkins and Build the CI pipeline
## Plugins 
Go to Jenkins -> Manage Jenkins -> Plugins -> Available plugins, and install the follwoing plugins:
1. Eclipse Temurin installer Plugin
2. NodeJS Plugin
3. SonarQube Scanner for Jenkins
Version
4. OWASP Dependency-Check Plugin
5. Docker API Plugin, Docker Commons Plugin, Docker Pipeline, Docker plugin

After plugins installation, configure the tools as follow:<br>
1. JDK
![jdk](https://github.com/waldra/Netflix-Clone/blob/main/images/jdk.png)
2. nodejs
![nodejs](https://github.com/waldra/Netflix-Clone/blob/main/images/nodejs.png)
3. SonarQube Scanner
![sonarqube](https://github.com/waldra/Netflix-Clone/blob/main/images/sonar-scanner.png)
4. OWASP dependency-check
![OWASP](https://github.com/waldra/Netflix-Clone/blob/main/images/dependency-check.png)
5. Docker
![docker](https://github.com/waldra/Netflix-Clone/blob/main/images/docker.png)
## Credentials configuration
1. GitHub <br>
step 1: Generate GitHub token <br>
Go to your GitHub account > settings > Developer settings > personal access tokens > Token classic > Generate new token.<br>
step 2: Configure the generated token on Jinkins <br>
Go to Jenkins > Manage Jenkins > Credentials > Add Credentials. In the username and password filed, enter your Github account username and the generated token.<br>
2. DockerHub<br>
Go to Jenkins > Manage Jenkins > Credentials > Add Credentials. Add your Dockerhub username and password.
3. mail<br>
step 1: Generate token on gmail<br>
Go to your gmail account -> Manage your Google Account -> Security -> 2-Step Verification -> App passwords. Enter your `App name` then enter create. Copy the generated token.<br>
step 2: Configure the generated token on Jenkins<br>
Go to Jenkins > Manage Jenkins > Credentials > Add Credentials. In the username and password filed, enter your gmail address and the generated gmail token.<br>
4. SonarQube<br>
step 1: Generate SonarQube token <br>
Go to SonarQube server > Administration > Security > Users > Tokens. Enter your `token-name`, Generate, and then Done.
step 2: Configure SonarQube token on Jenkins<br>
Go to Jenkins > Manage Jenkins > Credentials > Add Credentials. Select secret text and place the sonarqube token.
## SonarQube configuration
To integrate SonarQube server with Jenkins server. Go to your Jenkins server > Manage Jenkins > System. Scroll down to SonarQube Servers. Add the following enteries:
![sonarqube-server](https://github.com/waldra/Netflix-Clone/blob/main/images/sonarqube-server.png)
Configure webhook on SonarQube. Go to your SonarQube server > Administration > configuration > Webhooks > Create.
![webhook](https://github.com/waldra/Netflix-Clone/blob/main/images/webhook.png)
## SMTP configuration
We need to configure SMTP server on Jenkins for sending email notfications. We'll send email about trivy filesystem and image scan. To configure SMTP server, go to your Jenkins server > Manage Jenkins > System. Scroll down to Extended E-mail Notification.
![email](https://github.com/waldra/Netflix-Clone/blob/main/images/extended-email.png)
Then Scroll down to `Default Triggers` and check the following:
![trigger](https://github.com/waldra/Netflix-Clone/blob/main/images/trigger.png)
Finally, scroll down to `E-mail Notification` and set the following settings:
![notfication1](https://github.com/waldra/Netflix-Clone/blob/main/images/email-notification.png)
![notfication2](https://github.com/waldra/Netflix-Clone/blob/main/images/email-notification1.png)
## TMDB API Key
Go to [https://www.themoviedb.org/](https://www.themoviedb.org/) > Login > Click here. Fill up your details, go to API, generate API Key, copy the API Key, and then use the key for building docker image.
## Phase 3: Configure EKS Cluster and Build the CD pipeline
## helm installation
```bash
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt update
sudo apt install -y helm
```
## ArgoCD installation
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```
To get Argo CD initial-admin password, run the following command.
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
To access Argo CD UI, change Argo CD server service to loadbalancer.
```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```
## AWS loadBalancer Controller 
To install AWS LoadBalancer Controller on EKS cluster follow the steps: <br>
step 1: Create IAM Policy for AWS Loadbalancer controller.
```bash
curl -o iam-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.2.1/docs/install/iam_policy.json
aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam-policy.json
```
step 2: Create iamserviceaccount. Replace `your-account-id` with your real account ID.
```bash
eksctl create iamserviceaccount \
--cluster=eks-dev \
--namespace=kube-system \
--name=aws-load-balancer-controller \
--attach-policy-arn=arn:aws:iam::[your-account-id]:policy/AWSLoadBalancerControllerIAMPolicy \
--override-existing-serviceaccounts \
--approve
```
step 3: Install AWS Loadbalancer controller with helm. Replace `region` with your default region in AWS and `your-vpc-id` with your eks's vpc id.
```bash
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system \
--set clusterName=eks-dev \
--set serviceAccount.create=false \
--set serviceAccount.name=aws-load-balancer-controller \
--set region=eu-west-1 \
--set vpcId=[your-vpc-id]
```
## ExternalDNS Installation
step 1: Create IAM policy for ExternalDNS<br>
The following IAM Policy document allows ExternalDNS to update Route53 Resource Record Sets and Hosted Zones. Create IAM policy name `AllowExternalDNSUpdates` (but you can name it whatever you prefer).
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets",
        "route53:ListTagsForResource"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
```
If you are using the AWS CLI, you can run the following to install the above policy (saved as policy.json).
```bash
aws iam create-policy --policy-name "AllowExternalDNSUpdates" --policy-document file://policy.json
```
step 2: Create iamserviceaccount for ExternalDNS. Replace `Your-account-id` with you real AWS account ID.
```bash
eksctl create iamserviceaccount \
  --cluster eks-dev \
  --name "external-dns" \
  --namespace default \
  --attach-policy-arn arn:aws:iam::[Your-account-id]:policy/AmazonExternalDnsPolicy \
  --approve
```
step 3:  Create ExternalDns yaml file, name it `externaldns.yml` (but you can name it whatever you want), and copy the following manifest
```yml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: external-dns
rules:
- apiGroups: [""]
  resources: ["services","endpoints","pods"]
  verbs: ["get","watch","list"]
- apiGroups: ["extensions","networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get","watch","list"]
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["list","watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: external-dns-viewer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: external-dns
subjects:
- kind: ServiceAccount
  name: external-dns
  namespace: default
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns
spec:
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: external-dns
  template:
    metadata:
      labels:
        app: external-dns
      # If you're using kiam or kube2iam, specify the following annotation.
      # Otherwise, you may safely omit it.  #Change-2: Commented line 55 and 56
      #annotations:  
        #iam.amazonaws.com/role: arn:aws:iam::ACCOUNT-ID:role/IAM-SERVICE-ROLE-NAME    
    spec:
      serviceAccountName: external-dns
      containers:
      - name: external-dns
        image: k8s.gcr.io/external-dns/external-dns:v0.10.2
        args:
        - --source=service
        - --source=ingress
        # Change-3: Commented line 65 and 67 - --domain-filter=external-dns-test.my-org.com # will make ExternalDNS see only the hosted zones matching provided domain, omit to process all available hosted zones
        - --provider=aws
       # Change-3: Commented line 65 and 67  - --policy=upsert-only # would prevent ExternalDNS from deleting any records, omit to enable full synchronization
        - --aws-zone-type=public # only look at public hosted zones (valid values are public, private or no value for both)
        - --registry=txt
        - --txt-owner-id=my-hostedzone-identifier
      securityContext:
        fsGroup: 65534 # For ExternalDNS to be able to read Kubernetes and AWS token files
```
step 4: Deploy ExternalDns on EKS cluster
```bash
kubectl create -f externaldns.yml
```
## Phase 4: Setup and Configure Prometheus and Grafana
## Prometheus Installation
Step 1: Add the Helm chart repository for Prometheus and Grafana:
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```
Step 2: Install Prometheus Stack
```bash
helm install prometheus-stack prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace
```
Step 3: Access Grafana Dashboard
```bash
kubectl patch svc prometheus-stack-grafana -n monitoring -p '{"spec": {"type": "LoadBalancer"}}'
```
![Grafana](https://github.com/waldra/Netflix-Clone/blob/main/images/7.png)
