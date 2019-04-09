provider kubernetes {
  host = "${var.cluster_endpoint}"
  cluster_ca_certificate = "${base64decode(var.cluster_ca_certificate)}"
  client_certificate = "${base64decode(var.cluster_client_certificate)}"
  client_key = "${base64decode(var.cluster_client_key)}"

  username = "${var.cluster_master_auth_username}"
  password = "${var.cluster_master_auth_password}"

}


resource "kubernetes_deployment" "deployment" {
  metadata {
    name = "rs-${var.name}"
    labels {
      app = "${var.labels_app}"
      component = "${var.name}"
      language = "${var.labels_language}"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels {
        app = "${var.labels_app}"
        component = "${var.name}"
        language = "${var.labels_language}"
      }
    }
    strategy {
      rolling_update {
        max_surge = "25%"
        max_unavailable = "25%"
      }
      type = "RollingUpdate"
    }
    template {
      metadata {
        labels {
          app = "${var.labels_app}"
          component = "${var.name}"
          language = "${var.labels_language}"
        }
      }

      spec {
        restart_policy = "Always"
        image_pull_secrets {
          name = "${var.pull_secret}"
        }

        container {
          image = "${var.container_image}"
          image_pull_policy = "Always"
          name = "rs-${var.name}"

          port {
            container_port = "${var.container_port}"
            protocol = "TCP"
          }

          resources {
            limits {
              cpu = "${var.container_cpu_limit}"
              memory = "${var.container_memoy_limit}"
            }
            requests {
              cpu = "${var.container_cpu_request}"
              memory = "${var.container_memoy_request}"
            }
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = "${var.container_port}"
            }
            initial_delay_seconds = 3
            period_seconds = 30
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = "${var.container_port}"
            }
            initial_delay_seconds = 3
            period_seconds = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name = "rs-${var.name}"
    labels {
      app = "${var.labels_app}"
      component = "${var.name}"
      language = "${var.labels_language}"
    }
  }

  "spec" {
    port {
      port = 80
      name = "web"
      protocol = "TCP"
      target_port = "${var.container_port}"
    }
    selector {
      app = "${var.labels_app}"
      component = "${var.name}"
      language = "${var.labels_language}"
    }
    type = "NodePort"
  }
}

locals {
  affinity = {
    "spec" = {
      "template" = {
        "spec" = {
          "affinity" = {
            "podAntiAffinity" = {
              "requiredDuringSchedulingIgnoredDuringExecution" = [
                {
                  "labelSelector" = {
                    "matchExpressions" = [
                      {
                        "key" = "app",
                        "operator" = "In",
                        "values" = [
                          "${var.labels_app}"
                        ]
                      },
                      {
                        "key" = "component",
                        "operator" = "In",
                        "values" = [
                          "${var.name}"
                        ]
                      }
                    ]
                  },
                  "topologyKey" = "kubernetes.io/hostname"
                }
              ]
            }
          }
        }
      }
    }
  }
}

//TODO Antifiinity fix

//resource "local_file" "affinity_file" {
//  content = "${jsonencode(local.affinity)}"
//  filename = "${path.module}/affinity.json"
//}
//
//
//resource "null_resource" "affinity_patch" {
//  depends_on = [
//    "kubernetes_deployment.deployment"
//  ]
//
//
//  provisioner "local-exec" {
//    command = "kubectl patch --kubeconfig=${var.kubeconfig_file_path}  --server=https://${var.cluster_endpoint} --certificate-authority=${var.ca_cert_file_path} --token=${var.cluster_access_tokern} deployment rs-${var.name} --patch '${jsonencode(local.affinity)}'"
//  }
//}

resource "null_resource" "hpa" {
  count = "${var.create_hpa}"

  triggers {
    hpa = "${file("${var.hpa_file}")}"
  }

  provisioner "local-exec" {
    command = "kubectl apply  --kubeconfig=${var.kubeconfig_file_path}  --server=https://${var.cluster_endpoint} --certificate-authority=${var.ca_cert_file_path} --token=${var.cluster_access_tokern} -f ${var.hpa_file}"
  }
}
