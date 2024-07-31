locals {
  cp_node_list = [for i in range(var.talos_cp_node_count) : "${var.talos_cp_node_name_prefix}-${1 + i}"]
  talos_cp_node_overrides = {
    "talos-cp-1" = {
      "disk_gb" = 34
    }
  }

  talos_cp_node_settings = {

    for index, node in local.cp_node_list :
    node => merge(
      merge(var.talos_cp_node_defaults, { "ip" = "${var.localnet.subnet}.${var.talos_cp_node_base_ip + index}", "index" = index }),
      lookup(local.talos_cp_node_overrides, node, {})
    )
  }


  worker_node_list = [for i in range(var.talos_worker_node_count) : "${var.talos_worker_node_name_prefix}-${1 + i}"]

  talos_worker_node_overrides = {}

  talos_worker_node_settings = {

    for index, node in local.worker_node_list :
    node => merge(
      merge(var.talos_worker_node_defaults, { "ip" = "${var.localnet.subnet}.${var.talos_worker_node_base_ip + index}", "index" = index }),
      lookup(local.talos_worker_node_overrides, node, {})
    )
  }

  # Combine settings for all nodes
  vm_settings = merge(local.talos_cp_node_settings, local.talos_worker_node_settings)

  talos_cp_ip_addrs     = [for node in local.cp_node_list : local.vm_settings[node]["ip"]]
  talos_worker_ip_addrs = [for node in local.worker_node_list : local.vm_settings[node]["ip"]]
}