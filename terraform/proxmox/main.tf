provider "proxmox" {
  endpoint = var.proxmox_endpoint_url
  insecure = true
}

# Read SSH public key
data "local_file" "ssh_public_key" {
  filename = var.ssh_public_key_file
}

# Download Debian 13 Trixie cloud image
resource "proxmox_virtual_environment_download_file" "debian_cloud_image" {
  content_type = "import"
  datastore_id = var.snippets_datastore
  node_name    = var.proxmox_node
  url          = var.debian_image_url
  file_name    = "debian-13-generic-amd64.qcow2"
}

# Create cloud-init user-data file
resource "proxmox_virtual_environment_file" "user_data_cloud_config" {
  content_type = "snippets"
  datastore_id = var.snippets_datastore
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("${path.module}/cloud-init/user-data.yaml", {
      hostname       = var.hostname
      timezone       = var.timezone
      username       = var.username
      ssh_public_key = trimspace(data.local_file.ssh_public_key.content)
    })
    file_name = "${var.vm_name}-user-data.yaml"
  }
}

# Create cloud-init meta-data file
resource "proxmox_virtual_environment_file" "meta_data_cloud_config" {
  content_type = "snippets"
  datastore_id = var.snippets_datastore
  node_name    = var.proxmox_node

  source_raw {
    data = templatefile("${path.module}/cloud-init/meta-data.yaml", {
      hostname = var.hostname
      vm_name  = var.vm_name
    })
    file_name = "${var.vm_name}-meta-data.yaml"
  }
}

# Create the VM
resource "proxmox_virtual_environment_vm" "debian_vm" {
  machine     = "q35"
  name        = var.vm_name
  description = "Debian 13 Trixie VM with Docker, NFS, and Intel graphics support"
  tags        = ["terraform", "debian", "docker"]
  node_name   = var.proxmox_node
  vm_id       = var.vm_id

  # Enable QEMU guest agent
  agent {
    enabled = true
  }

  # CPU configuration
  cpu {
    cores = var.vm_cpu_cores
    type  = "host"
  }

  # Memory configuration
  memory {
    dedicated = var.vm_memory
  }

  # Disk configuration
  disk {
    datastore_id = var.vm_disk_datastore
    file_id      = proxmox_virtual_environment_download_file.debian_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = var.vm_disk_size
  }

  # Network configuration
  network_device {
    bridge = var.network_bridge
  }

  # Cloud-init configuration
  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_data_file_id = proxmox_virtual_environment_file.user_data_cloud_config.id
    meta_data_file_id = proxmox_virtual_environment_file.meta_data_cloud_config.id
  }

  # Serial device for proper console access
  serial_device {
    device = "socket"
  }

  # Operating system type
  operating_system {
    type = "l26" # Linux 2.6/3.x/4.x/5.x kernel
  }

  # Stop the VM gracefully on destroy (important when guest agent is not ready)
  stop_on_destroy = true

  # Startup configuration
  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }

  hostpci {
    device = "hostpci0"
    id     = "0000:00:02"
    pcie   = true
    rombar = true
    xvga   = false
  }

  lifecycle {
    ignore_changes = [
      disk[0].file_id
    ]
  }
}
