resource "google_container_cluster" "primary" {

  name = "${var.platform_name}-cluster"

  zone = "${var.gcloud_zone}"

  master_auth {
    username = "${var.cluster_master_auth_username}"
    password = "${var.cluster_master_auth_password}"
  }


  node_pool {
    autoscaling {
      max_node_count = "${var.cluster_node_pool_max_size}"
      min_node_count = "${var.cluster_node_pool_min_size}"
    }
    initial_node_count = "${var.cluster_node_initial_count}"

    node_config {
      machine_type = "${var.cluster_node_machine_type}"

      oauth_scopes = [
        "https://www.googleapis.com/auth/projecthosting",
        "https://www.googleapis.com/auth/devstorage.full_control",
        "https://www.googleapis.com/auth/monitoring",
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/compute",
        "https://www.googleapis.com/auth/cloud-platform"
      ]
    }
  }


}

provider "kubernetes" {
  host = "${google_container_cluster.primary.endpoint}"
  username = "${google_container_cluster.primary.master_auth.0.username}"
  password = "${google_container_cluster.primary.master_auth.0.password}"
  client_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
  client_key = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"


}


resource "kubernetes_service_account" "tiller" {

  depends_on = [
    "google_container_cluster.primary"]

  metadata {
    name = "tiller"
    namespace = "kube-system"
  }

  automount_service_account_token = true
}

resource "kubernetes_cluster_role_binding" "tiller" {
  depends_on = [
    "kubernetes_service_account.tiller"]

  metadata {
    name = "tiller-cluster-admin"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }

  subject {
    api_group = ""
    kind = "ServiceAccount"
    name = "tiller"
    namespace = "kube-system"
  }
}