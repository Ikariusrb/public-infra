variable "proxmox" {
  type = object({
    host_list    = list(string)
    storage_pool = string
    vlan         = number
  })
  description = <<EOT
    host_list: List of Proxmox hosts - used for distributing VMs across hosts
      Multiple hosts is only supported if you have a cluster
      If you only have one host, just put it in the list
    storage_pool: Proxmox storage pool to deploy VMs on. If deploying to a cluster, this should be a shared storage pool
    vlan: VLAN tag for VMs; -1 (default) disables tagging
  EOT
}

variable "localnet" {
  type = object({
    domain     = string
    dns_ip     = string
    ip_gateway = string
    subnet     = string
  })
  description = <<EOT
    Local network configuration;
      domain: DNS domain for local hosts
      dns_ip: IP of DNS resolver
      gateway: default gateway IP
      subnet: Local subnet first 3 octets - code assumes a /24 subnet
  EOT
}

variable "talos_cluster_name" {
  type    = string
  default = "homelab-talos"
}

variable "talos_version" {
  description = "version of Talos to deploy"
  default     = "v1.7.5"
}

variable "talos_cp_vip_ip" {
  type        = string
  description = "IP address to use for the control plane VIP"
}

variable "talos_cp_node_count" {
  type        = number
  description = "Number of control plane nodes to deploy"
  default     = 3
}

variable "talos_cp_node_base_ip" {
  type        = number
  description = "Starting IP address for control plane nodes - IPs will be assigned sequentially starting with this value"
}

variable "talos_cp_node_name_prefix" {
  type        = string
  description = "Prefix to use for control plane node names"
  default     = "talos-cp"
}

variable "talos_cp_node_defaults" {
  type = object({
    cpu_cores = number
    memory    = number
    disk_gb   = number
    template  = string
  })
  description = "default configuration values to be used for control plane nodes"
}

# variable "talos_cp_node_overrides" {
#   type = map(object({
#     memory    = optional(number)
#     cpu_cores = optional(number)
#     disk_gb   = optional(number)
#     template  = optional(string)
#   }))
#   description = "override values for individual control plane nodes"
#   default     = {}
# }

variable "talos_worker_node_count" {
  type        = number
  description = "Number of worker nodes to deploy"
  default     = 3
}

variable "talos_worker_node_base_ip" {
  type        = number
  description = "Starting IP address for worker nodes - IPs will be assigned sequentially starting with this value"
}

variable "talos_worker_node_name_prefix" {
  type        = string
  description = "Prefix to use for control plane node names"
  default     = "talos-worker"
}

variable "talos_worker_node_defaults" {
  type = object({
    memory    = number
    cpu_cores = number
    disk_gb   = number
    template  = string
  })
  description = "default configuration values to be used for worker nodes"
}

# variable "talos_worker_node_overrides" {
#   type = map(object({
#     memory    = optional(number)
#     cpu_cores = optional(number)
#     disk_gb   = optional(number)
#     template  = optional(string)
#   }))
#   description = "override values for individual worker nodes"
#   default     = {}
# }
