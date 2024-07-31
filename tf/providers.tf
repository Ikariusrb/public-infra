terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
    pihole = {
      source  = "ryanwholey/pihole"
      version = "0.2.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.5.0"
    }
  }
}

provider "pihole" {
  url = "https://pihole.mydomain.net"
}

provider "proxmox" {
  pm_api_url  = "https://proxmox-1.mydomain.net:8006/api2/json"
  pm_parallel = 2
}
