# HOW TO USE:
# add following to your terraform config
#module "libcloud-dynamic-dns" {
#  source = "github.com/gumlooter/libcloud-dynamic-dns"
#  module_count = 1 # 0 to turn it off
#  node_pool = google_container_node_pool.nodes
#  persistent_disk = "development-storage"
#  service_account_name = "SERVICE_ACCOUNT_NAME@YOUR_PROJECT.iam.gserviceaccount.com"
#  service_account_json = "{\n  \"type\": \"service_account\",\"...........}"
#  subdomain = "www"
#  zone = "example.com."
#  project_name = "google_project"
#}

# calculate local vars based on input vars
locals {
  # decide to run or not to run based on count input
  onoff_switch = var.module_count != 1 ? 0 : 1
}

# schedule deployment
resource "kubernetes_deployment" "dynamic-dns" {
  # create resource only if there it's required
  count = local.onoff_switch

  metadata {
    name = var.deployment_name
  }
  
  # wait for gke node pool
  depends_on = [var.node_pool, kubernetes_config_map.service-account-json]

  spec {
    # we need only one replica of the service
    replicas = 1

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    # pod configuration
    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        # attach json to node
        volume {
          name= "config"
          config_map {
            name = "service-account-json"
          }
        }

        # specify container 
        container {
          name = var.container_name
          image = var.image

          # all the env settings
          # update freq
          env {
            name = "DNS_UPD_FREQ"
            value = var.script_update_frequency
          }
          
          # subdomain
          env {
            name = "A_RECORD_NAME"
            value = var.subdomain
          }
          
          # zone
          env {
            name = "A_RECORD_ZONE_NAME"
            value = var.zone
          }
          
          # dns ttl
          env {
            name = "A_RECORD_TTL_SECONDS"
            value = var.dns_ttl
          }
          
          env {
            name = "DNS_PROJECT_NAME"
            value = var.project_name
          }

          # service account id
          env {
            name = "DNS_USER_ID"
            value = var.service_account_name
          }
          
          # path with key file
          env {
            name = "DNS_KEY_PATH"
            value = "${var.service_account_json_path}/${var.service_account_json_name}"
            
          }          
                 
          # mount disk to container
          volume_mount {
            mount_path = var.service_account_json_path
            name = "config"
          }      
        }
      }      
    }
  }
}

resource "kubernetes_config_map" "service-account-json" {
  metadata {
    name = "service-account-json"
  }

  data = {
    "${var.service_account_json_name}" = var.service_account_json
  }
}

