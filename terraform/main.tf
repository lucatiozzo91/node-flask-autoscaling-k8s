provider "google" {
  project     = "${var.gcloud_project}"
  region      = "${var.gcloud_region}"
  zone    = "${var.gcloud_zone}"
}

data "google_client_config" "current" {}

module "cluster" {
  source = "./cluster"
  gcloud_project = "${var.gcloud_project}"
  gcloud_region = "${var.gcloud_region}"
  gcloud_zone = "${var.gcloud_zone}"

  platform_name = "${var.platform_name}"

  cluster_node_machine_type = "${var.cluster_node_machine_type}"
  cluster_node_initial_count = "${var.cluster_node_initial_count}"

  cluster_master_auth_username = "${var.cluster_master_auth_username}"
  cluster_master_auth_password = "${var.cluster_master_auth_password}"

  cluster_access_token = "${data.google_client_config.current.access_token}"

  cluster_node_pool_min_size = "${var.cluster_node_pool_min_size}"
  cluster_node_pool_max_size = "${var.cluster_node_pool_max_size}"

}

resource "local_file" "ca_cert_file" {

  content = "${base64decode(module.cluster.cluster_ca_certificate)}"
  filename = "${path.module}/ca.pem"
}

resource "local_file" kubeconfig {
  content = ""
  filename = "${path.module}/kubeconfig"
}


resource "null_resource" "pull_secret" {

  triggers {
    username= "${var.pull_secret_username}"
    docker-password = "${var.pull_secret_password}"
    docker-email = "${var.pull_secret_email}"
    docker-server = "${var.registry_url}"
    name = "${var.pull_secret}"
  }

  depends_on = [
    "local_file.ca_cert_file",
    "local_file.kubeconfig",
  ]


  provisioner "local-exec" {
    command = "kubectl --kubeconfig=${path.module}/kubeconfig --server=https://${module.cluster.cluster_endpoint} --certificate-authority=${path.module}/ca.pem --token=${data.google_client_config.current.access_token} create secret docker-registry ${var.pull_secret} --docker-server=${var.registry_url} --docker-username=${var.pull_secret_username} --docker-password=${var.pull_secret_password} --docker-email=${var.pull_secret_email}"
  }
}

module "network" {
  source = "./network"

  cluster_region = "${var.gcloud_region}"

  static_ip_name = "${var.static_ip_name}"
}


module "monitoring" {

  source = "./monitoring"

  cluster_master_auth_username = "${var.cluster_master_auth_username}"
  cluster_master_auth_password = "${var.cluster_master_auth_password}"

  cluster_ca_certificate = "${module.cluster.cluster_ca_certificate}"
  cluster_client_certificate = "${module.cluster.client_certificate}"
  cluster_endpoint = "${module.cluster.cluster_endpoint}"
  cluster_client_key = "${module.cluster.client_key}"
  cluster_access_token = "${data.google_client_config.current.access_token}"

  tiller_account_name = "${module.cluster.tiller_account_name}"
  tiller_account_namespace = "${module.cluster.tiller_account_namespace}"
}


module "rs-order" {

  source = "./rs"

  ca_cert_file_path = "${local_file.ca_cert_file.filename}"
  kubeconfig_file_path = "${local_file.kubeconfig.filename}"

  cluster_access_tokern = "${data.google_client_config.current.access_token}"

  cluster_master_auth_username = "${var.cluster_master_auth_username}"
  cluster_master_auth_password = "${var.cluster_master_auth_password}"

  cluster_ca_certificate = "${module.cluster.cluster_ca_certificate}"
  cluster_client_certificate = "${module.cluster.client_certificate}"
  cluster_endpoint = "${module.cluster.cluster_endpoint}"
  cluster_client_key = "${module.cluster.client_key}"
  cluster_access_token = "${data.google_client_config.current.access_token}"

  pull_secret = "${var.pull_secret}"

  name = "order"

  labels_language = "python"
  container_port = "5000"
  container_image = "myregistry/order:latest"
  labels_app = "rs"
}

module "rs-product" {
  source = "./rs"

  ca_cert_file_path = "${local_file.ca_cert_file.filename}"
  kubeconfig_file_path = "${local_file.kubeconfig.filename}"

  cluster_access_tokern = "${data.google_client_config.current.access_token}"

  cluster_master_auth_username = "${var.cluster_master_auth_username}"
  cluster_master_auth_password = "${var.cluster_master_auth_password}"

  cluster_ca_certificate = "${module.cluster.cluster_ca_certificate}"
  cluster_client_certificate = "${module.cluster.client_certificate}"
  cluster_endpoint = "${module.cluster.cluster_endpoint}"
  cluster_client_key = "${module.cluster.client_key}"
  cluster_access_token = "${data.google_client_config.current.access_token}"

  pull_secret = "${var.pull_secret}"

  name = "product"

  labels_language = "node"
  container_port = "3000"
  container_image = "myregistry/product:latest"
  labels_app = "rs"

  create_hpa = "1"
  hpa_file = "../k8s/product-hpa.yaml"

}

module "rs-user" {
  source = "./rs"

  ca_cert_file_path = "${local_file.ca_cert_file.filename}"
  kubeconfig_file_path = "${local_file.kubeconfig.filename}"

  cluster_access_tokern = "${data.google_client_config.current.access_token}"

  cluster_master_auth_username = "${var.cluster_master_auth_username}"
  cluster_master_auth_password = "${var.cluster_master_auth_password}"

  cluster_ca_certificate = "${module.cluster.cluster_ca_certificate}"
  cluster_client_certificate = "${module.cluster.client_certificate}"
  cluster_endpoint = "${module.cluster.cluster_endpoint}"
  cluster_client_key = "${module.cluster.client_key}"
  cluster_access_token = "${data.google_client_config.current.access_token}"

  pull_secret = "${var.pull_secret}"

  name = "user"

  labels_language = "go"
  container_port = "8080"
  container_image = "myregistry/user:latest"
  labels_app = "rs"
}

module "ingress" {
  source = "./ingress"

  ca_cert_file_path = "${local_file.ca_cert_file.filename}"
  kubeconfig_file_path = "${local_file.kubeconfig.filename}"

  ingress_ip = "${module.network.ingress-ip}"

  cluster_access_tokern = "${data.google_client_config.current.access_token}"

  cluster_master_auth_username = "${var.cluster_master_auth_username}"
  cluster_master_auth_password = "${var.cluster_master_auth_password}"

  cluster_ca_certificate = "${module.cluster.cluster_ca_certificate}"
  cluster_client_certificate = "${module.cluster.client_certificate}"
  cluster_endpoint = "${module.cluster.cluster_endpoint}"
  cluster_client_key = "${module.cluster.client_key}"
  cluster_access_token = "${data.google_client_config.current.access_token}"

  tiller_account_name = "${module.cluster.tiller_account_name}"
  tiller_account_namespace = "${module.cluster.tiller_account_namespace}"

}


module "gitlab" {
  source = "./gitlab"

  cluster_name = "${module.cluster.cluster_name}"
  cluster_endpoint = "${module.cluster.cluster_endpoint}"
  gitlab_project_id = "${var.gitlab_project_id}"
  cluster_ca_certificate = "${module.cluster.cluster_ca_certificate}"
  cluster_access_tokern  = "${data.google_client_config.current.access_token}"
}