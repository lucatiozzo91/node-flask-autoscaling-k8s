

resource gitlab_project_cluster "bar" {
  project                       = "${var.gitlab_project_id}"
  name                          = "${var.cluster_name}"
  enabled                       = true
  kubernetes_api_url            = "https://${var.cluster_endpoint}"
  kubernetes_token              = "${var.cluster_access_tokern}"
  kubernetes_ca_cert            = "${base64decode(var.cluster_ca_certificate)}"
  kubernetes_namespace          = "default"
  kubernetes_authorization_type = "rbac"
  environment_scope             = "*"
}