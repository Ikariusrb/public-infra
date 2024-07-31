# Copy this file to terraform.tfvars and edit to make it reflect your environment
# Proxmox Configuration
proxmox = {
  host_list    = ["proxmox-1", "proxmox-2", "proxmox-3"]
  storage_pool = "nfs-images"
  vlan         = -1
}

# local network configuration
localnet = {
  domain     = "mydomain.net"
  dns_ip     = "192.168.10.10"
  ip_gateway = "192.168.10.1"
  subnet     = "192.168.10"
}

# Talos Configuration
talos_version = "v1.7.5"

talos_cp_vip_ip       = "192.168.10.100"
talos_cp_node_count   = 3
talos_cp_node_base_ip = 80
talos_cp_node_defaults = {
  "memory"    = 4096
  "cpu_cores" = 2
  "disk_gb"   = 32
  "template"  = "talos-nocloud"
}

talos_worker_node_count   = 3
talos_worker_node_base_ip = 85
talos_worker_node_defaults = {
  "memory"    = 8192
  "cpu_cores" = 4
  "disk_gb"   = 96
  "template"  = "talos-nocloud"
}
