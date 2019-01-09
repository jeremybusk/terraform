#!/bin/bash
# For Base install of Ubuntu Bionic or Debian Buster.
set -exo pipefail
TERRAFORM_VERSION="0.11.11"

# Prep with gitlab-runner
# curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
# sudo gitlab-runner register

sudo apt-get install -y qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virt-manager
sudo apt-get install -y golang-go libvirt-dev unzip

echo "security_driver=\"none\"" >> /etc/libvirt/qemu.conf
sudo systemctl restart libvirt-bin
# ref: https://github.com/dmacvicar/terraform-provider-libvirt/commit/22f096d9 

cd /tmp
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
cp terraform /usr/local/bin/

sudo -iu gitlab-runner -- <<EOF
cd /tmp
go get github.com/dmacvicar/terraform-provider-libvirt
go install github.com/dmacvicar/terraform-provider-libvirt
sudo -u gitlab-runner mkdir -p ~/.terraform.d
cp ~/go/bin/terraform-provider-libvirt ~/.terraform.d/
EOF

USER="gitlab-runner"
sudo adduser $USER sudo
sudo adduser $USER libvirt
