#!/bin/bash
set -e

echo "=== Update ==="
sudo dnf update -y

echo "=== Base Tools ==="
sudo dnf install -y \
git jq wget vim unzip tar \
python3 python3-pip \
maven docker \
dnf-plugins-core

echo "=== Java 21 ==="
sudo dnf install -y java-21-amazon-corretto-devel

sudo alternatives --set java \
/usr/lib/jvm/java-21-amazon-corretto/bin/java

echo 'export JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto' | sudo tee /etc/profile.d/java.sh
echo 'export PATH=$JAVA_HOME/bin:$PATH' | sudo tee -a /etc/profile.d/java.sh

source /etc/profile.d/java.sh

echo "=== Node.js 22 LTS ==="
curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
sudo dnf install -y nodejs

echo "=== Docker ==="
sudo systemctl enable docker
sudo systemctl start docker

echo "=== GitHub CLI ==="
sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
sudo rpm --import https://cli.github.com/packages/githubcli-archive-keyring.asc
sudo dnf install -y gh

echo "=== kubectl ==="
curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "=== Helm ==="
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "=== Terraform ==="
TF_VERSION="1.13.1"
curl -L -o terraform.zip \
https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip

unzip -o terraform.zip
sudo mv terraform /usr/local/bin/

echo "=== eksctl ==="
curl --silent --location \
https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz \
| tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin/

echo "=== ArgoCD CLI ==="
sudo curl -sSL \
-o /usr/local/bin/argocd \
https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

sudo chmod +x /usr/local/bin/argocd

echo
echo "=========== VERIFY ==========="

java -version
mvn -version
node -v
npm -v
docker --version
python3 --version
gh --version
kubectl version --client
helm version
terraform version
argocd version --client
eksctl version

echo
echo "✅ DevOps Bastion Ready"
