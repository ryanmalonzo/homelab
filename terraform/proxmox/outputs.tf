# Output the VM's IP address
output "vm_ipv4_address" {
  description = "The IPv4 address of the VM"
  value       = proxmox_virtual_environment_vm.debian_vm.ipv4_addresses[1][0]
  depends_on  = [proxmox_virtual_environment_vm.debian_vm]
}

# Output the VM ID
output "vm_id" {
  description = "The VM ID in Proxmox"
  value       = proxmox_virtual_environment_vm.debian_vm.vm_id
}

# Output the VM name
output "vm_name" {
  description = "The name of the VM"
  value       = proxmox_virtual_environment_vm.debian_vm.name
}

# Output SSH connection command
output "ssh_connection_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ${var.username}@${proxmox_virtual_environment_vm.debian_vm.ipv4_addresses[1][0]}"
  depends_on  = [proxmox_virtual_environment_vm.debian_vm]
}

# Output Docker verification command
output "docker_verification_command" {
  description = "Command to verify Docker installation via SSH"
  value       = "ssh ${var.username}@${proxmox_virtual_environment_vm.debian_vm.ipv4_addresses[1][0]} 'docker --version && docker ps'"
  depends_on  = [proxmox_virtual_environment_vm.debian_vm]
}

# Output useful VM information
output "vm_info" {
  description = "Summary of VM configuration"
  value = {
    name     = proxmox_virtual_environment_vm.debian_vm.name
    node     = proxmox_virtual_environment_vm.debian_vm.node_name
    cores    = var.vm_cpu_cores
    memory   = "${var.vm_memory} MB"
    disk     = "${var.vm_disk_size} GB"
    username = var.username
    hostname = var.hostname
  }
}