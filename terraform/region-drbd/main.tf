provider "libvirt" {
  uri = "qemu+ssh://${var.connection_uri}/system"
}

resource "libvirt_domain" "default" {
  count = var.instance.count

  name = "node-${count.index + var.instance.offset}"
  # cpu = <mode>
  vcpu = 2
  memory = "2048"
  # running = false
  autostart = true

  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id

  network_interface {
    network_id     = libvirt_network.k8snet.id
    hostname       = "node-${count.index + var.instance.offset}"
  }

  network_interface {
    network_id     = libvirt_network.drbdnet.id
  }

  disk {
    volume_id = libvirt_volume.master[count.index].id
    scsi      = "true"
  }

  disk {
    volume_id = libvirt_volume.drbd[count.index].id
    scsi      = "true"
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }
}

resource "libvirt_network" "k8snet" {
  # the name used by libvirt
  name = "k8snet-${var.instance.offset}"

  # mode can be: "nat" (default), "none", "route", "bridge"
  mode = "bridge"
  bridge = "br0"
}

resource "libvirt_network" "drbdnet" {
  # the name used by libvirt
  name = "drbdnet-${var.instance.offset}"
  addresses = ["192.168.254.0/24"]

  # mode can be: "nat" (default), "none", "route", "bridge"
  # mode = "nat"
  mode = "bridge"
  bridge = "br1"
}

resource "libvirt_pool" "ubuntu" {
  name = "ubuntu-${var.instance.offset}"
  type = "dir"
  path = "/tmp/terraform-provider-libvirt-pool-ubuntu-${var.instance.offset}"
}

resource "libvirt_volume" "ubuntu1804" {
  name   = "ubuntu1804"
  pool   = libvirt_pool.ubuntu.name
  source = "https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img"
}

# volume to attach to the "master" domain as main disk
resource "libvirt_volume" "master" {
  count = var.instance.count

  name           = "master-${count.index + var.instance.offset}.qcow2"
  base_volume_id = libvirt_volume.ubuntu1804.id
  size           = 1024 * 1024 *1024 * 20
}

resource "libvirt_volume" "drbd" {
  count = var.instance.count

  name           = "drbd-${count.index + var.instance.offset}.qcow2"
  size           = 1024 * 1024 *1024 * 10
}

resource "libvirt_cloudinit_disk" "commoninit" {
  count = var.instance.count

  name           = "commoninit-${count.index + var.instance.offset}.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config[count.index].rendered
  pool           = libvirt_pool.ubuntu.name
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")

  vars = {
    key = file("~/.ssh/id_rsa.pub")
  }
}

data "template_file" "network_config" {
  count = var.instance.count

  template = file("${path.module}/network_config.cfg")
  vars = {
    ipv4_address = cidrhost(format("%s/%s", var.instance.ipv4_network, var.instance.ipv4_netmask), count.index + var.instance.offset)
    ipv4_netmask = var.instance.ipv4_netmask
    gateway4 = var.instance.gateway4
    nameservers = var.instance.nameservers
    ipv4_drbd_address = cidrhost("192.168.5.0/24", count.index + 11)
    ipv4_drbd_netmask = "24"
  }
}
