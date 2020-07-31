# terraform

![enter image description here](./assets/objective.drawio.svg)

## Setup DRBD

1. Update IP address in `region-drbd/terraform.tfvars.json` and `inventory`
2. Create nodes   
    <details>
    <summary>terraform apply -auto-approve</summary>
    <pre class="language-shell"><code>
    > cd region-drbd
    > terraform apply -auto-approve
    data.template_file.user_data: Refreshing state...
    data.template_file.network_config[1]: Refreshing state...
    data.template_file.network_config[0]: Refreshing state...
    libvirt_pool.ubuntu: Creating...
    libvirt_volume.drbd[1]: Creating...
    libvirt_volume.drbd[0]: Creating...
    libvirt_network.drbdnet: Creating...
    libvirt_network.k8snet: Creating...
    libvirt_volume.drbd[1]: Creation complete after 0s [id=/var/lib/libvirt/images/drbd-105.qcow2]
    libvirt_volume.drbd[0]: Creation complete after 1s [id=/var/lib/libvirt/images/drbd-104.qcow2]
    libvirt_pool.ubuntu: Creation complete after 5s [id=b8954422-64fa-4a5d-98d1-d1846be99748]
    libvirt_network.k8snet: Creation complete after 5s [id=d8b98f26-cd1f-4737-a6e0-9372a7d52c8b]
    libvirt_cloudinit_disk.commoninit[1]: Creating...
    libvirt_cloudinit_disk.commoninit[0]: Creating...
    libvirt_volume.ubuntu1804: Creating...
    libvirt_network.drbdnet: Creation complete after 6s [id=de4b3548-bdbd-4d3c-aa94-c560b185d372]
    libvirt_cloudinit_disk.commoninit[1]: Still creating... [10s elapsed]
    libvirt_cloudinit_disk.commoninit[0]: Still creating... [10s elapsed]
    libvirt_volume.ubuntu1804: Still creating... [10s elapsed]
    libvirt_cloudinit_disk.commoninit[1]: Still creating... [20s elapsed]
    libvirt_cloudinit_disk.commoninit[0]: Still creating... [20s elapsed]
    libvirt_volume.ubuntu1804: Still creating... [20s elapsed]
    libvirt_cloudinit_disk.commoninit[1]: Still creating... [30s elapsed]
    libvirt_cloudinit_disk.commoninit[0]: Still creating... [30s elapsed]
    libvirt_volume.ubuntu1804: Still creating... [30s elapsed]
    libvirt_cloudinit_disk.commoninit[1]: Still creating... [40s elapsed]
    libvirt_cloudinit_disk.commoninit[0]: Still creating... [40s elapsed]
    libvirt_volume.ubuntu1804: Still creating... [40s elapsed]
    libvirt_cloudinit_disk.commoninit[1]: Still creating... [50s elapsed]
    libvirt_volume.ubuntu1804: Still creating... [50s elapsed]
    libvirt_cloudinit_disk.commoninit[0]: Still creating... [50s elapsed]
    libvirt_cloudinit_disk.commoninit[1]: Still creating... [1m0s elapsed]
    libvirt_volume.ubuntu1804: Still creating... [1m0s elapsed]
    libvirt_cloudinit_disk.commoninit[0]: Still creating... [1m0s elapsed]
    libvirt_volume.ubuntu1804: Creation complete after 1m6s [id=/tmp/terraform-provider-libvirt-pool-ubuntu-104/ubuntu1804]
    libvirt_cloudinit_disk.commoninit[0]: Creation complete after 1m7s [id=/tmp/terraform-provider-libvirt-pool-ubuntu-104/commoninit-104.iso;5f245810-c664-0320-72de-15abacd52ba8]
    libvirt_cloudinit_disk.commoninit[1]: Creation complete after 1m7s [id=/tmp/terraform-provider-libvirt-pool-ubuntu-104/commoninit-105.iso;5f245810-ec50-4c75-54bb-77614b85c82b]
    libvirt_volume.master[1]: Creating...
    libvirt_volume.master[0]: Creating...
    libvirt_volume.master[1]: Creation complete after 0s [id=/var/lib/libvirt/images/master-105.qcow2]
    libvirt_volume.master[0]: Creation complete after 1s [id=/var/lib/libvirt/images/master-104.qcow2]
    libvirt_domain.default[0]: Creating...
    libvirt_domain.default[1]: Creating...
    libvirt_domain.default[1]: Creation complete after 3s [id=01444773-7cea-4898-99c5-fce62e9ff298]
    libvirt_domain.default[0]: Creation complete after 3s [id=a21cdb15-6a44-4634-8371-badfe1173f8a]

    Apply complete! Resources: 12 added, 0 changed, 0 destroyed.
    </code></pre>
    </details>

3. Setup DRBD
   
    <details>
    <summary>ansible-playbook playbook.yml</summary>
    <pre class="language-shell"><code>
    > ansible-playbook playbook.yml

    PLAY [drbd_nodes] **********************************************************************************************************************************************************************************************************************

    TASK [Gathering Facts] *****************************************************************************************************************************************************************************************************************
    ok: [drbd1]
    ok: [drbd2]

    TASK [apt-update : debian | hostname] **************************************************************************************************************************************************************************************************
    changed: [drbd2]
    changed: [drbd1]

    TASK [apt-update : include_tasks] ******************************************************************************************************************************************************************************************************
    included: /home/u/workspace/kube/terraform/roles/apt-update/tasks/debian.yml for drbd1, drbd2

    TASK [apt-update : debian | updating packages] *****************************************************************************************************************************************************************************************
    ...
    </code></pre>
    </detail>

4. Test block device

    <details>
    <summary>virsh -c qemu+ssh://127.0.0.1/system console node-104</summary>
    <pre class="language-shell"><code>
    > virsh -c qemu+ssh://127.0.0.1/system console node-104
    Connected to domain node-104
    Escape character is ^]

    Ubuntu 18.04.4 LTS drbd1 ttyS0

    drbd1 login: ubuntu
    Password:
    Last login: Fri Jul 31 17:57:53 UTC 2020 from 10.144.48.106 on pts/0
    Welcome to Ubuntu 18.04.4 LTS (GNU/Linux 4.15.0-112-generic x86_64)

    ubuntu@drbd1:~$ ls /opt/nfs
    ubuntu@drbd1:~$ touch /opt/nfs/a
    ubuntu@drbd1:~$ sudo drbd-overview
    ubuntu@drbd1:~$ sudo shutdown now
    > virsh -c qemu+ssh://127.0.0.1/system console node-105
    ubuntu@drbd2:~$ ls /opt/nfs
    a
    </code></pre>
    </detail>

5. Release node

    <details>
    <summary>terraform destroy -auto-approve</summary>
    <pre class="language-shell"><code>
    > terraform destroy -auto-approve
    </code></pre>
    </detail>

