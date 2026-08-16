#!/bin/bash

set -Eeuo pipefail

trap 'echo "[ERROR] Installation failed at line $LINENO"; exit 1' ERR

echo
echo "============================================================"
echo " Jenkins LTS + Java 21 Installation"
echo "============================================================"
echo

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

JAVA_VERSION="21"
JAVA_HOME="/usr/lib/jvm/java-21-amazon-corretto"
JAVA_BIN="${JAVA_HOME}/bin/java"

JENKINS_REPO="https://pkg.jenkins.io/rpm-stable/jenkins.repo"
JENKINS_KEY="https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key"

CORRETTO_KEY="https://yum.corretto.aws/corretto.key"
CORRETTO_REPO="https://yum.corretto.aws/corretto.repo"
CORRETTO_RPM_URL="https://corretto.aws/downloads/latest/amazon-corretto-21-x64-linux-jdk.rpm"

# ------------------------------------------------------------
# Root check
# ------------------------------------------------------------

if [ "$(id -u)" -ne 0 ]; then
    echo "[ERROR] Run this script with sudo:"
    echo
    echo "sudo ./install-jenkins.sh"
    exit 1
fi

# ------------------------------------------------------------
# OS detection
# ------------------------------------------------------------

echo "[INFO] Detecting operating system..."

if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "[ERROR] Cannot detect operating system."
    exit 1
fi

echo "[INFO] OS: ${PRETTY_NAME}"

if [ "${ID:-}" = "amzn" ] && [ "${VERSION_ID:-}" = "2" ]; then
    echo "[WARN] Amazon Linux 2 detected."
    echo "[WARN] Amazon Linux 2 reached end of support on June 30, 2026."
    echo "[WARN] For new production servers, prefer Amazon Linux 2023."
fi

# ------------------------------------------------------------
# Architecture
# ------------------------------------------------------------

ARCH="$(uname -m)"

case "$ARCH" in
    x86_64)
        CORRETTO_RPM_URL="https://corretto.aws/downloads/latest/amazon-corretto-21-x64-linux-jdk.rpm"
        ;;
    aarch64|arm64)
        CORRETTO_RPM_URL="https://corretto.aws/downloads/latest/amazon-corretto-21-aarch64-linux-jdk.rpm"
        ;;
    *)
        echo "[ERROR] Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "[INFO] Architecture: $ARCH"

# ------------------------------------------------------------
# Basic packages
# ------------------------------------------------------------

echo
echo "============================================================"
echo " Installing required packages"
echo "============================================================"

yum install -y curl wget ca-certificates

# ------------------------------------------------------------
# Update package metadata
# ------------------------------------------------------------

echo
echo "[INFO] Updating package metadata..."

yum clean metadata
yum makecache

# ------------------------------------------------------------
# Install Corretto repository
# ------------------------------------------------------------

echo
echo "============================================================"
echo " Installing Amazon Corretto 21"
echo "============================================================"

rpm --import "$CORRETTO_KEY"

curl -fsSL "$CORRETTO_REPO" \
    -o /etc/yum.repos.d/corretto.repo

# ------------------------------------------------------------
# Install Java 21
# ------------------------------------------------------------

if rpm -q java-21-amazon-corretto-devel >/dev/null 2>&1; then

    echo "[INFO] Java 21 Corretto is already installed."

else

    echo "[INFO] Downloading official Amazon Corretto 21 RPM..."

    cd /tmp

    rm -f amazon-corretto-21.rpm

    curl -fL \
        -o amazon-corretto-21.rpm \
        "$CORRETTO_RPM_URL"

    echo "[INFO] Installing Java 21..."

    yum install -y ./amazon-corretto-21.rpm

    rm -f amazon-corretto-21.rpm

fi

# ------------------------------------------------------------
# Verify Java 21 installation
# ------------------------------------------------------------

if [ ! -x "$JAVA_BIN" ]; then

    echo "[ERROR] Java 21 binary was not found:"
    echo "$JAVA_BIN"

    echo
    echo "[INFO] Installed Java packages:"
    rpm -qa | grep -i corretto || true

    exit 1
fi

echo
echo "[INFO] Java 21 binary:"
echo "$JAVA_BIN"

# ------------------------------------------------------------
# Configure alternatives
# ------------------------------------------------------------

echo
echo "[INFO] Configuring Java 21 as system default..."

if ! alternatives --display java 2>/dev/null | grep -Fq "$JAVA_BIN"; then

    alternatives --install \
        /usr/bin/java \
        java \
        "$JAVA_BIN" \
        2100

fi

alternatives --set java "$JAVA_BIN"

# ------------------------------------------------------------
# Verify active Java
# ------------------------------------------------------------

echo
echo "============================================================"
echo " Java verification"
echo "============================================================"

java -version

ACTIVE_JAVA="$(readlink -f "$(command -v java)")"

echo
echo "[INFO] Active Java:"
echo "$ACTIVE_JAVA"

if [ "$ACTIVE_JAVA" != "$JAVA_BIN" ]; then

    echo "[ERROR] Java 21 is not the active Java."
    echo "[ERROR] Expected:"
    echo "$JAVA_BIN"
    echo "[ERROR] Actual:"
    echo "$ACTIVE_JAVA"

    exit 1
fi

echo "[OK] Java 21 is active."

# ------------------------------------------------------------
# Remove Java 17 AFTER Java 21 is verified
# ------------------------------------------------------------

echo
echo "[INFO] Checking for Java 17..."

if rpm -q java-17-amazon-corretto >/dev/null 2>&1 || \
   rpm -q java-17-amazon-corretto-devel >/dev/null 2>&1; then

    echo "[INFO] Removing Java 17..."

    yum remove -y \
        java-17-amazon-corretto \
        java-17-amazon-corretto-devel \
        || true

else

    echo "[INFO] Java 17 is not installed as an RPM."

fi

# Re-select Java 21 after removal
alternatives --set java "$JAVA_BIN"

# ------------------------------------------------------------
# DevOps Toolchain (AL2023)

dnf update -y

dnf install -y java-21-amazon-corretto-devel maven docker python3 python3-pip gh unzip curl wget tar git jq vim

systemctl enable docker

systemctl start docker

curl -fsSL https://rpm.nodesource.com/setup_22.x | bash -

dnf install -y nodejs

curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x kubectl && mv kubectl /usr/local/bin/

curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

TF_VERSION=1.13.1

curl -L -o terraform.zip https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip

unzip -o terraform.zip && mv terraform /usr/local/bin/

curl --silent --location https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz | tar xz -C /tmp

mv /tmp/eksctl /usr/local/bin/

curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

chmod +x /usr/local/bin/argocd

# Jenkins repository
# ------------------------------------------------------------

echo
echo "============================================================"
echo " Configuring official Jenkins LTS repository"
echo "============================================================"

curl -fsSL "$JENKINS_REPO" \
    -o /etc/yum.repos.d/jenkins.repo

rpm --import "$JENKINS_KEY"

yum clean metadata
yum makecache

# ------------------------------------------------------------
# Install Jenkins
# ------------------------------------------------------------

echo
echo "============================================================"
echo " Installing Jenkins LTS"
echo "============================================================"

if rpm -q jenkins >/dev/null 2>&1; then

    echo "[INFO] Jenkins is already installed."

else

    yum install -y jenkins

fi

# ------------------------------------------------------------
# Configure Jenkins explicitly for Java 21
# ------------------------------------------------------------

echo
echo "============================================================"
echo " Configuring Jenkins to use Java 21"
echo "============================================================"

mkdir -p /etc/systemd/system/jenkins.service.d

cat > /etc/systemd/system/jenkins.service.d/java21.conf <<CONF
[Service]
Environment="JAVA_HOME=${JAVA_HOME}"
Environment="JENKINS_JAVA_CMD=${JAVA_BIN}"
CONF

# ------------------------------------------------------------
# Reload systemd
# ------------------------------------------------------------

systemctl daemon-reload

# ------------------------------------------------------------
# Enable Jenkins
# ------------------------------------------------------------

echo
echo "[INFO] Enabling Jenkins at boot..."

systemctl enable jenkins

# ------------------------------------------------------------
# Start Jenkins
# ------------------------------------------------------------

echo
echo "[INFO] Starting Jenkins..."

systemctl restart jenkins

# ------------------------------------------------------------
# Wait for Jenkins
# ------------------------------------------------------------

echo
echo "[INFO] Waiting for Jenkins to start..."

for i in {1..30}; do

    if systemctl is-active --quiet jenkins; then
        echo "[OK] Jenkins is running."
        break
    fi

    sleep 2

done

# ------------------------------------------------------------
# Verify Jenkins
# ------------------------------------------------------------

if ! systemctl is-active --quiet jenkins; then

    echo
    echo "[ERROR] Jenkins failed to start."

    echo
    echo "----- Jenkins status -----"
    systemctl status jenkins --no-pager -l || true

    echo
    echo "----- Jenkins logs -----"
    journalctl -u jenkins -n 100 --no-pager || true

    exit 1

fi

# ------------------------------------------------------------
# Verify Jenkins Java
# ------------------------------------------------------------

echo
echo "============================================================"
echo " Jenkins Java verification"
echo "============================================================"

JENKINS_PID="$(systemctl show -p MainPID --value jenkins)"

echo "[INFO] Jenkins PID: $JENKINS_PID"

if [ "$JENKINS_PID" != "0" ]; then

    echo
    echo "[INFO] Jenkins Java executable:"

    readlink -f "/proc/${JENKINS_PID}/exe" || true

    echo
    echo "[INFO] Jenkins command:"

    tr '\0' ' ' < "/proc/${JENKINS_PID}/cmdline" || true

    echo

fi

# ------------------------------------------------------------
# Network verification
# ------------------------------------------------------------

echo
echo "============================================================"
echo " Jenkins network check"
echo "============================================================"

if command -v ss >/dev/null 2>&1; then
    ss -lntp | grep ':8080' || true
fi

# ------------------------------------------------------------
# Initial password
# ------------------------------------------------------------

echo
echo "============================================================"
echo " Jenkins installation complete"
echo "============================================================"

echo
echo "Jenkins status:"
systemctl is-active jenkins

echo
echo "Java version:"
java -version

echo
echo "Jenkins initial admin password:"

if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    cat /var/lib/jenkins/secrets/initialAdminPassword
else
    echo "[INFO] Password file is not available yet."
    echo
    echo "Try:"
    echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
fi

echo
echo "Jenkins URL:"
echo "http://YOUR_EC2_PUBLIC_IP:8080"

echo
echo "Useful commands:"
echo "  sudo systemctl status jenkins"
echo "  sudo systemctl restart jenkins"
echo "  sudo journalctl -u jenkins -f"
echo
echo "============================================================"
