#!/bin/bash

echo "================================="
echo "      DEVOPS TOOL VERSIONS"
echo "================================="

printf "\nJAVA      : "
java -version 2>&1 | head -1

printf "MAVEN     : "
mvn -version 2>/dev/null | head -1

printf "NODE      : "
node -v 2>/dev/null

printf "NPM       : "
npm -v 2>/dev/null

printf "PYTHON    : "
python3 --version 2>/dev/null

printf "DOCKER    : "
docker --version 2>/dev/null

printf "GH        : "
gh --version 2>/dev/null | head -1

printf "KUBECTL   : "
kubectl version --client 2>/dev/null | head -1

printf "HELM      : "
helm version --short 2>/dev/null

printf "TERRAFORM : "
terraform version 2>/dev/null | head -1

printf "ARGOCD    : "
argocd version --client 2>/dev/null | head -1

printf "EKSCTL    : "
eksctl version 2>/dev/null

printf "AWS CLI   : "
aws --version 2>&1

echo
echo "================================="
echo "      BINARY LOCATIONS"
echo "================================="

which java mvn node npm python3 docker gh kubectl helm terraform argocd eksctl aws 2>/dev/null

echo
echo "================================="
echo "      JENKINS STATUS"
echo "================================="

systemctl is-active jenkins 2>/dev/null || echo "jenkins not found"

echo
echo "================================="
echo "      CHECK COMPLETE"
echo "================================="
