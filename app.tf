resource "kubernetes_deployment" "php_apache" {
  metadata {
    name = "php-apache"
    labels = {
      app = "php-apache"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "php-apache"
      }
    }

    template {
      metadata {
        labels = {
          app = "php-apache"
        }
      }

      spec {
        container {
          image = "k8s.gcr.io/hpa-example"
          name  = "php-apache"

          resources {
            limits = {
              cpu    = "500m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "64Mi"
            }
          }

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "php_apache" {
  metadata {
    name = "php-apache"
  }

  spec {
    selector = {
      app = kubernetes_deployment.php_apache.metadata[0].labels.app
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "ClusterIP"
  }
}

# resource "kubernetes_horizontal_pod_autoscaler" "php_apache" {
#   metadata {
#     name = "php-apache"
#   }

#   spec {
#     scale_target_ref {
#       kind        = "Deployment"
#       name        = kubernetes_deployment.php_apache.metadata[0].name
#       api_version = "apps/v1"
#     }

#     min_replicas = 1
#     max_replicas = 10

#     metric {
#       type = "Resource"

#       resource {
#         name = "cpu"

#         target {
#           type                = "Utilization"
#           average_utilization = 40
#         }
#       }
#     }
#   }
# }
