resource "pihole_dns_record" "k8s-nodes-dns" {
  for_each = local.vm_settings
  domain   = "${each.key}.${var.localnet.domain}"
  ip       = each.value["ip"]
}

resource "proxmox_vm_qemu" "proxmox-vms" {
  for_each    = local.vm_settings
  target_node = var.proxmox.host_list[each.value["index"] % length(var.proxmox.host_list)]
  desc        = "Cloudinit Talos"
  onboot      = true
  clone       = each.value["template"]
  agent       = 1
  os_type     = "cloud-init"
  cores       = each.value["cpu_cores"]
  sockets     = 1
  numa        = true
  vcpus       = 0
  cpu         = "host"
  memory      = each.value["memory"]
  name        = each.key
  scsihw      = "virtio-scsi-single"
  bootdisk    = "scsi0"

  disks {
    scsi {
      scsi0 {
        disk {
          storage = var.proxmox.storage_pool
          size    = each.value["disk_gb"]
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = var.proxmox.storage_pool
        }
      }
    }
  }
  network {
    bridge    = "vmbr0"
    firewall  = false
    link_down = false
    model     = "virtio"
    tag       = var.proxmox.vlan
  }

  ipconfig0  = "ip=${each.value["ip"]}/24,gw=${var.localnet.ip_gateway}"
  nameserver = var.localnet.dns_ip
}
