#!/bin/bash
set -Eeuo pipefail

echo "=============================================="
echo " Jenkins + Java 21 Installation"
echo " Amazon Linux 2023"
echo "=============================================="

# Must run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run with: sudo ./install-jenkins.sh"
    exit 1
fi

echo "[1/8] Updating system..."
dnf update -y

echo "[2/8] Installing required packages..."
dnf install -y wget curl fontconfig

echo "[3/8] Installing Java 21 Amazon Corretto..."
dnf install -y java-21-amazon-corretto

echo "[4/8] Configuring Java 21..."
alternatives --set java /usr/lib/jvm/java-21-amazon-corretto/bin/java || true

echo "[5/8] Adding official Jenkins repository..."
wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/rpm-stable/jenkins.repo

rpm --import \
    https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key

echo "[6/8] Installing Jenkins..."
dnf clean all
dnf makecache
dnf install -y jenkins

echo "[7/8] Enabling and starting Jenkins..."
systemctl daemon-reload
systemctl enable jenkins
systemctl restart jenkins

sleep 10

echo "[8/8] Verifying installation..."

echo
echo "========== JAVA =========="
java -version

echo
echo "========== JENKINS =========="
systemctl --no-pager -l status jenkins

echo
echo "========== JENKINS PORT =========="
ss -lntp | grep ':8080' || true

echo
echo "=============================================="
echo " Jenkins installation completed!"
echo "=============================================="

echo
echo "Jenkins URL:"
echo "http://YOUR_EC2_PUBLIC_IP:8080"

echo
echo "Initial Jenkins password:"
cat /var/lib/jenkins/secrets/initialAdminPassword

echo
echo "=============================================="
echo "IMPORTANT:"
echo "Allow TCP port 8080 in your EC2 Security Group."
echo "=============================================="
