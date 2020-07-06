# Terraform

## Reference

- 基本 virsh 使用: https://linuxconfig.org/how-to-create-and-manage-kvm-virtual-machines-from-cli#h9-create-the-new-virtual-machine
- How To Provision VMs on KVM (libvirtd) with Terraform: https://computingforgeeks.com/how-to-provision-vms-on-kvm-with-terraform/
- Configuring a libvirt domain with a static IP address via cloud-init local datasource: https://gist.github.com/cjihrig/a0f0e3c058b4d9dcf9ca1f771916fa28
- [Terraform] 入門學習筆記: https://godleon.github.io/blog/DevOps/terraform-getting-started/

## Install

```bash
/etc/libvirt/qemu.conf
security_driver = "none"
```

Install terraform, terrafrom_libvirt
Write libvirt.tf
Write cloud_init.cfg

terraform init
terraform plan
terraform apply
terraform show
terraform destroy

Provision
Variable
Module

terraform -var=libvirt_uri=qemu+ssh://u@host1/system -var=node_number=17 apply
terraform -var=uri=qemu+ssh://u@host1/system -var=node=18 apply
terraform -var=uri=qemu+ssh://u@host2:2200/system -var=node=33 apply

virsh
virsh list --all
virsh undefined ubuntu-terraform3
virsh net-dhcp-leases default
virsh net-define ./virsh5.xml
virsh net-list -a
virsh net-autostart k8s
virsh net-start k8s
virsh net-dumpxml k8s

