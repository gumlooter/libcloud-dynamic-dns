# external variables 
variable "module_count" {}
variable "node_pool" {}
variable "persistent_disk" {}
variable "service_account_name" {}
variable "service_account_json" {}
variable "subdomain" {}
variable "zone" {}
variable "project_name" {}

#internal variables
variable "name" {
  default="ddns"
}

variable "image" {
  default="gumlooter/libcloud-dynamic-dns:latest"
}
  
variable "service_account_json_path" {
  default="/config"
}

variable "service_account_json_name" {
  default="account.json"
}


variable "script_update_frequency" {
  default="3600"
}

variable "dns_ttl" {
  default="60"
}
