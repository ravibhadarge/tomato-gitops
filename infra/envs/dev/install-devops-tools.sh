#!/bin/bash
set -e

exec > >(tee /var/log/user-data.log) 2>&1

echo "===== UPDATE ====="

dnf update -y

echo "===== BASE PACKAGES ====="
dnf install -y curl --allowerasing

dnf install -y \
git \
jq \
wget \
vim \
unzip \
tar \
python3 \
python3-pip \
maven \
docker \
java-21-amazon-corretto-devel \
fontconfig \
dnf-plugins-core

echo "===== JAVA 21 ====="

cat >/etc/profile.d/java21.sh <<'EOF'
export JAVA_HOME=/usr/lib/jvm/java-21-amazon-corretto
export PATH=$JAVA_HOME/bin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin
EOF

source /etc/profile.d/java21.sh

echo "===== JENKINS ====="

wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/rpm-stable/jenkins.repo

rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key

dnf upgrade -y
dnf install -y jenkins

systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

echo "===== NODEJS 22 ====="

curl -fsSL https://rpm.nodesource.com/setup_22.x | bash -
dnf install -y nodejs

echo "===== DOCKER ====="

systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

echo "===== GITHUB CLI ====="

dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
rpm --import https://cli.github.com/packages/githubcli-archive-keyring.asc
dnf install -y gh

echo "===== KUBECTL ====="

curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

echo "===== HELM ====="

curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "===== TERRAFORM ====="

TF_VERSION="1.13.1"

curl -L -o terraform.zip \
https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip

unzip -o terraform.zip
mv terraform /usr/local/bin/
rm -f terraform.zip

echo "===== EKSCTL ====="

curl --silent --location \

