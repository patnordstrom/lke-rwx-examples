variable "region" {
  type        = string
  description = "Linode region to deploy"
  default     = "us-ord"
}

variable "nfs_server_label" {
  type        = string
  description = "Label for NFS server"
  default     = "test-lke-rwx-nfs-server"
}

variable "lke_cluster_label" {
  type        = string
  description = "Label for NFS server"
  default     = "test-lke-rwx-lke-cluster"
}

variable "image_name" {
  type        = string
  description = "The image we will deploy all nodes with."
  # Only certain images are compatible with cloud-init by default.
  # Refer to the guide below for compatible platform provided images 
  # https://www.linode.com/docs/products/compute/compute-instances/guides/metadata/#availability
  default = "linode/ubuntu24.04"
}

variable "nfs_image_type" {
  type        = string
  description = "The image type to deploy all nodes with."
  default     = "g6-nanode-1"
}

variable "lke_image_type" {
  type        = string
  description = "The image type to deploy all nodes with."
  default     = "g6-standard-1"
}

variable "authorized_users" {
  type        = list(string)
  description = "List of users who has SSH keys imported into cloud manager who need access"
}

variable "allowed_ssh_user_ips" {
  type        = list(string)
  description = "List of IP addresses that can SSH into the server"
}

variable "k8s_version" {
  type        = string
  description = "The version of LKE to deploy.  Default not provided because changes frequently."
}