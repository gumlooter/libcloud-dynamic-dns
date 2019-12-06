# external variables 
variable "module_count" {}
variable "node_pool" {}
variable "persistent_disk" {}

#internal variables
variable "app_name" {
  default="ddns"
}

variable "container_name" {
  default="ddns-container"
}

variable "deployment_name" {
  default="ddns-deployment"
}

variable "image" {
  default="gumlooter/libcloud-dynamic-dns:latest"
}
  
variable "persistent_mount_path" {
  default="/usr/src/app/config"
}
