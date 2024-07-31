resource "talos_machine_secrets" "machine_secrets" {
  talos_version = var.talos_version
}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.talos_cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = local.talos_cp_ip_addrs
  nodes                = concat(local.talos_cp_ip_addrs, local.talos_worker_ip_addrs)
}

data "talos_machine_configuration" "machineconfig_cp" {
  cluster_name     = var.talos_cluster_name
  cluster_endpoint = "https://${local.talos_cp_ip_addrs[0]}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
  config_patches = [jsonencode({ machine : {
    network : {
      interfaces : [
        { interface : "eth0"
          vip : {
            ip : var.talos_cp_vip_ip
        } },
      ]
    } } }
  )]
}

resource "talos_machine_configuration_apply" "cp_config_apply" {
  count                       = length(local.talos_cp_ip_addrs)
  depends_on                  = [proxmox_vm_qemu.proxmox-vms]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_cp.machine_configuration
  node                        = local.talos_cp_ip_addrs[count.index]
}

data "talos_machine_configuration" "machineconfig_worker" {
  cluster_name     = var.talos_cluster_name
  cluster_endpoint = "https://${local.talos_cp_ip_addrs[0]}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

resource "talos_machine_configuration_apply" "worker_config_apply" {
  count                       = length(local.talos_worker_ip_addrs)
  depends_on                  = [proxmox_vm_qemu.proxmox-vms]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_worker.machine_configuration
  node                        = local.talos_worker_ip_addrs[count.index]
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on           = [talos_machine_configuration_apply.cp_config_apply]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.talos_cp_ip_addrs[0]
}

resource "time_sleep" "wait_for_talos_api" {
  depends_on      = [talos_machine_bootstrap.bootstrap]
  create_duration = "60s"
}

data "talos_cluster_health" "health" {
  depends_on           = [time_sleep.wait_for_talos_api, talos_machine_configuration_apply.cp_config_apply, talos_machine_configuration_apply.worker_config_apply]
  client_configuration = data.talos_client_configuration.talosconfig.client_configuration
  control_plane_nodes  = local.talos_cp_ip_addrs
  worker_nodes         = local.talos_worker_ip_addrs
  endpoints            = data.talos_client_configuration.talosconfig.endpoints
}

resource "time_sleep" "wait_for_kubeconfig" {
  depends_on      = [talos_machine_bootstrap.bootstrap, data.talos_cluster_health.health]
  create_duration = "60s"
}

data "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [talos_machine_bootstrap.bootstrap, data.talos_cluster_health.health]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.talos_cp_ip_addrs[0]
}

resource "local_file" "talosconfig" {
  content  = data.talos_client_configuration.talosconfig.talos_config
  filename = "${path.module}/../_out/talosconfig"
}

resource "local_file" "kubeconfig" {
  content  = data.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  filename = "${path.module}/../_out/kubeconfig"
}


output "talosconfig" {
  value     = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = data.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}

