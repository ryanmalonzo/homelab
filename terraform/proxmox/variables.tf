variable "proxmox_endpoint_url" {
  description = "The Proxmox VE API endpoint URL"
  type        = string
  default     = "https://192.168.1.35:8006/"
}

variable "proxmox_node" {
  description = "The Proxmox node name where the VM will be created"
  type        = string
  default     = "pve"
}

variable "vm_name" {
  description = "The name of the virtual machine"
  type        = string
  default     = "docker"
}

variable "vm_id" {
  description = "The VM ID (optional, will be auto-assigned if not specified)"
  type        = number
  default     = null
}

variable "vm_cpu_cores" {
  description = "Number of CPU cores for the VM"
  type        = number
  default     = 4
}

variable "vm_memory" {
  description = "Amount of memory (RAM) in MB"
  type        = number
  default     = 8192
}

variable "vm_disk_size" {
  description = "Size of the VM disk in GB"
  type        = number
  default     = 100
}

variable "vm_disk_datastore" {
  description = "Datastore for the VM disk"
  type        = string
  default     = "local-lvm"
}

variable "snippets_datastore" {
  description = "Datastore for cloud-init snippets"
  type        = string
  default     = "local"
}

variable "network_bridge" {
  description = "Network bridge for the VM"
  type        = string
  default     = "vmbr0"
}

variable "ssh_public_key_file" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "../../ssh/key.pub"
}

variable "username" {
  description = "Username for the VM user account"
  type        = string
  default     = "chaldea"
}

variable "hostname" {
  description = "Hostname for the VM"
  type        = string
  default     = "docker"
}

variable "timezone" {
  description = "Timezone for the VM"
  type        = string
  default     = "Europe/Paris"
}

variable "debian_image_url" {
  description = "URL for the Debian 13 Trixie genericcloud image"
  type        = string
  default     = "https://cdimage.debian.org/cdimage/cloud/trixie/latest/debian-13-genericcloud-amd64.qcow2"
}
