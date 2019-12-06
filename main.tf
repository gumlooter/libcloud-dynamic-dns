# HOW TO USE:
# add following to your terraform config
#module "libcloud-dynamic-dns" {
#  source = "git@github.com:gumlooter/libcloud-dynamic-dns.git"
#  module_count = 1 # 0 to turn it off
#  node_pool = google_container_node_pool.nodes
#  persistent_disk = "development-storage"
#}

# calculate local vars based on input vars
locals {
  # decide to run or not to run based on count input
  onoff_switch = var.module_count != 1 ? 0 : 1
}

# schedule Jupyter Notebook
resource "kubernetes_deployment" "jupyter" {
  # create resource only if there it's required
  count = local.onoff_switch

  metadata {
    name = var.deployment_name
  }
  
  # wait for gke node pool
  depends_on = [var.node_pool]

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
        # attach persistent-disk to node
        volume {
          name= "persistent-volume"
          gce_persistent_disk {
            pd_name = var.persistent_disk
          }
        }

        # specify container 
        container {
          name = var.container_name
          image = var.image
          command = var.command
          args = local.args

          # mount disk to container
          volume_mount {
            mount_path = var.persistent_mount_path
            name = "persistent-volume"
          }      
        }
      }      
    }
  }
}
