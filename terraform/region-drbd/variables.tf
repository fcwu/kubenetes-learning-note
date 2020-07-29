variable "instance" {
  description = "virtual machine template"

  type = object({
    count = number
    offset = number
    ipv4_network = string
    ipv4_netmask = string
    gateway4 = string
    nameservers = string
  })
  default = {
    count = 1
    offset = 2
    ipv4_network = "192.168.0.0"
    ipv4_netmask = "24"
    gateway4 = "192.168.0.1"
    nameservers = "[\"8.8.8.8\"]"
  }
}

variable "connection_uri" {
  description = "ssh uri connecting to libvirt"

  type = string
  default = "ubuntu@localhost"
}

