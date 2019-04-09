provider "helm" {

  install_tiller  = true
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.11.0"
  service_account = "${var.tiller_account_name}"
  namespace       = "${var.tiller_account_namespace}"

  kubernetes {
    host                   = "${var.cluster_endpoint}"
    cluster_ca_certificate = "${base64decode(var.cluster_ca_certificate)}"
    client_certificate = "${base64decode(var.cluster_client_certificate)}"
    client_key = "${base64decode(var.cluster_client_key)}"

    username = "${var.cluster_master_auth_username}"
    password = "${var.cluster_master_auth_password}"

  }
}


resource "helm_release" "prometheus" {
  name      = "monitoring"
  chart     = "stable/prometheus-operator"
  namespace = "default"

  values = [
    "${file("../monitoring/prometheus/values.yaml")}",
  ]
}

//adapter for calculate metrics for hpa and expose metrics
resource "helm_release" "prometheus-adapter" {
  name      = "adapter"
  chart     = "stable/prometheus-adapter"
  namespace = "default"

  values = [
    "${file("../monitoring/adapter/values.yaml")}",
  ]
}


data "local_file" "products_dashboard" {
    filename = "../monitoring/rs-product-dashboard.json"

}

provider kubernetes {
  host                   = "${var.cluster_endpoint}"
  cluster_ca_certificate = "${base64decode(var.cluster_ca_certificate)}"
  client_certificate = "${base64decode(var.cluster_client_certificate)}"
  client_key = "${base64decode(var.cluster_client_key)}"

  username = "${var.cluster_master_auth_username}"
  password = "${var.cluster_master_auth_password}"

}

resource "kubernetes_config_map" "example" {

  depends_on = ["helm_release.prometheus"]

  metadata {
      name = "products-dashboard-grafana-config"
      labels {
        grafana_dashboard= "products-dashboard"
}

  }

  data {
    products_dashboard.json = "${data.local_file.products_dashboard.content}"
  }
}