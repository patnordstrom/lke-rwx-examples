locals {
  linode_private_ip_range = "192.168.128.0/17"
}

resource "random_password" "root_pass" {
  length  = 30
  special = true
}

resource "linode_instance" "nfs_server" {
  label            = var.nfs_server_label
  region           = var.region
  image            = var.image_name
  type             = var.nfs_image_type
  root_pass        = random_password.root_pass.result
  authorized_users = var.authorized_users
  private_ip       = true
  metadata {
    user_data = filebase64("../cloud-init/nfs-server-config.yaml")
  }
}

data "linode_instances" "lke_nodes" {
  filter {
    name   = "id"
    values = [for item in linode_lke_cluster.lke_nfs_testing_cluster.pool[0].nodes : item.instance_id]
  }
}

resource "linode_firewall" "nfs_server_fw" {
  label           = "${var.nfs_server_label}-fw"
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  inbound {
    label    = "allow-ssh-from-my-computer"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = var.allowed_ssh_user_ips
  }

  inbound {
    label    = "allow-nfs-from-k8s-nodes"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "2049"
    ipv4     = [for item in data.linode_instances.lke_nodes.instances : "${item.private_ip_address}/32"]
  }

  linodes = [linode_instance.nfs_server.id]

}

# see recommended firewall rules here:  
# https://www.linode.com/docs/products/compute/kubernetes/get-started/#general-network-and-firewall-information
resource "linode_firewall" "lke_cluster_fw" {
  label           = "${var.lke_cluster_label}-fw"
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"

  inbound {
    label    = "kubelet-health-checks"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "10250"
    ipv4     = [local.linode_private_ip_range]
  }

  inbound {
    label    = "calico-bgp"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "179"
    ipv4     = [local.linode_private_ip_range]
  }

  inbound {
    label    = "wireguard-proxy"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "51820"
    ipv4     = [local.linode_private_ip_range]
  }

  inbound {
    label    = "nodeport-range-tcp"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "30000-32767"
    ipv4     = [local.linode_private_ip_range]
  }

  inbound {
    label    = "nodeport-range-udp"
    action   = "ACCEPT"
    protocol = "UDP"
    ports    = "30000-32767"
    ipv4     = [local.linode_private_ip_range]
  }

  inbound {
    label    = "encapsulated-internode-traffic"
    action   = "ACCEPT"
    protocol = "IPENCAP"
    ports    = ""
    ipv4     = [local.linode_private_ip_range]
  }

  linodes = [for item in linode_lke_cluster.lke_nfs_testing_cluster.pool[0].nodes : item.instance_id]

}

resource "linode_lke_cluster" "lke_nfs_testing_cluster" {
  label       = var.lke_cluster_label
  k8s_version = var.k8s_version
  region      = var.region

  pool {
    type  = var.lke_image_type
    count = 3
  }

}