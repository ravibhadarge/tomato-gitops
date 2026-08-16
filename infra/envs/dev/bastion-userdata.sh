#!/bin/bash
set -eux

# Update
yum update -y

# Basic tools
yum install -y git jq unzip wget curl vim docker java-17-amazon-corretto-devel

systemctl enable docker
systemctl start docker

# AWS CLI
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip -q awscliv2.zip
./aws/install

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Terraform
wget -q https://releases.hashicorp.com/terraform/1.13.1/terraform_1.13.1_linux_amd64.zip
unzip -oq terraform_1.13.1_linux_amd64.zip
mv terraform /usr/local/bin/

# eksctl
curl --silent --location \
https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz \
| tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin/

# ArgoCD CLI
curl -sSL -o /usr/local/bin/argocd \
https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd

# k9s
curl -sL https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz \
| tar -xz
mv k9s /usr/local/bin/

# Jenkins CLI
wget -q -O /usr/local/bin/jenkins-cli.jar \
https://updates.jenkins.io/latest/jenkins-cli.jar

# Create helper install script
cat >/home/ec2-user/install-platform.sh <<'SCRIPT'
#!/bin/bash
set -e

# Jenkins
helm repo add jenkins https://charts.jenkins.io
helm repo update

helm upgrade --install jenkins jenkins/jenkins \
  -n jenkins \
  --create-namespace \
  --set controller.admin.username=admin \
  --set controller.admin.password='Admin@123'

# RabbitMQ
helm repo add bitnami https://charts.bitnami.com/bitnami

helm upgrade --install rabbitmq bitnami/rabbitmq \
  -n rabbitmq \
  --create-namespace \
  --set auth.username=admin \
  --set auth.password='Admin@123' \
  --set auth.erlangCookie='RabbitCookie123'

echo "Done"
SCRIPT

chmod +x /home/ec2-user/install-platform.sh
chown ec2-user:ec2-user /home/ec2-user/install-platform.sh

echo "Bastion Ready" > /tmp/bastion-ready.txt
