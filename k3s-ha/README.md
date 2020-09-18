# terraform

![enter image description here](assets/objective.drawio.svg)

## Configurations

### Controller

- install terraform
- install terraform plugin - libvird https://github.com/dmacvicar/terraform-provider-libvirt
- install python, kubespary requirements
- install kubectl
- install LANS

### Host

```bash
sudo apt install -y libvirt-daemon
sudo usermod -aG kvm $USER
newgrp kvm
```

test on controller

```bash
virsh -c qemu+ssh://127.0.0.1/system list --all
```

## Region A

bring up machines

```bash
cd region-a
terraform apply
ssh ubuntu@10.144.48.112
```

```bash
# Install dependencies from ``requirements.txt``
sudo pip3 install -r requirements.txt

# Copy ``inventory/sample`` as ``inventory/mycluster``
cp -rfp inventory/sample inventory/mycluster

# Update Ansible inventory file with inventory builder
declare -a IPS=(10.144.48.112 10.144.48.113 10.144.48.114)
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

# Review and change parameters under ``inventory/mycluster/group_vars``
cat inventory/mycluster/group_vars/all/all.yml
cat inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml

# Deploy Kubespray with Ansible Playbook - run the playbook as root
# The option `--become` is required, as for example writing SSL keys in /etc/,
# installing packages and interacting with various systemd daemons.
# Without --become the playbook will fail to run!
ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root cluster.yml
```

Add node

ansible-playbook -i inventory/mycluster/hosts.yml scale.yml -b -v \
  --private-key=~/.ssh/private_key

Remove node

ansible-playbook -i inventory/mycluster/hosts.yml remove-node.yml -b -v \
--private-key=~/.ssh/private_key \
--extra-vars "node=nodename,nodename2"

https://github.com/mrlesmithjr/ansible-etc-hosts
https://blog.pichuang.com.tw/20180622-suggestions_to_improve_your_ansible_playbook/
ansible-playbook -c local -i localhost, ini.yaml