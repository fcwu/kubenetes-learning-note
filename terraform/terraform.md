https://vagrantcloud.com/generic/boxes/ubuntu1804/versions/3.0.10/providers/libvirt.box

vagrant box add generic/ubuntu1804 --provider libvirt
ls -l ~/.vagrant.d/boxes/generic-VAGRANTSLASH-ubuntu1804/3.0.10/libvirt/

user add kvm group
libvirt-daemon

1 master

1 worker
1 worker