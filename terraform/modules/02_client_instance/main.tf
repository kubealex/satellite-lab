terraform {
 required_version = ">= 1.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.0"
    }
  }
}

resource "libvirt_volume" "os_image_rhel8" {
  name = "${var.hostname}-os_image"
  pool = var.libvirt_pool
  format = "qcow2"
  size = var.disk_size*1073741824
}

resource "libvirt_volume" "kickstart_image_rhel8" {
  name = "${var.hostname}-kickstart_rhel8"
  pool = var.libvirt_pool
  source = abspath("${path.module}/${var.kickstart_image_rhel8}")
  format = "qcow2"
}

resource "libvirt_volume" "os_image_rhel9" {
  name = "${var.hostname}-os_image_rhel9"
  pool = var.libvirt_pool
  format = "qcow2"
  size = var.disk_size*1073741824
}

resource "libvirt_volume" "kickstart_image_rhel9" {
  name = "${var.hostname}-kickstart_rhel9"
  pool = var.libvirt_pool
  source = abspath("${path.module}/${var.kickstart_image_rhel9}")
  format = "qcow2"
}

resource "libvirt_domain" "el8-server" {
  autostart = true
  name = "el8-server"
  memory = var.memory*1024
  vcpu = var.cpu

  boot_device {
    dev = ["hd", "cdrom", "network"]
  }

  cpu {
    mode = "host-passthrough"
  }

  disk {
     file = abspath("${path.module}/${var.os_image_rhel8}")
  }

  disk {
     volume_id = libvirt_volume.os_image_rhel8.id
  }

  disk {
     volume_id = libvirt_volume.kickstart_image_rhel8.id
  }

  network_interface {
     network_name = var.libvirt_network
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = "true"
  }
}

resource "libvirt_domain" "el9-server" {
  autostart = true
  name = "el9-server"
  memory = var.memory*1024
  vcpu = var.cpu

  boot_device {
    dev = ["hd", "cdrom", "network"]
  }

  cpu {
    mode = "host-passthrough"
  }

  disk {
     file = abspath("${path.module}/${var.os_image_rhel9}")
  }

  disk {
     volume_id = libvirt_volume.os_image_rhel9.id
  }

  disk {
     volume_id = libvirt_volume.kickstart_image_rhel9.id
  }

  network_interface {
       network_name = var.libvirt_network
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = "true"
  }
}
