variable "cluster_endpoint" {}
variable "cluster_access_token" {}
variable "cluster_client_certificate" {}
variable "cluster_client_key" {}
variable "cluster_ca_certificate" {}

variable "cluster_access_tokern" {}

variable "name" {}

variable "labels_app" {}
variable "labels_language" {}

variable "cluster_master_auth_username" {}
variable "cluster_master_auth_password" {}

variable "create_hpa" {default = 0}
variable "hpa_file" {default = ""}

variable "pull_secret" {}
variable "container_image" {}

variable "container_port" {}

variable "container_cpu_limit" {
  default = "100m"
}
variable "container_memoy_limit" {
  default = "150Mi"
}
variable "container_cpu_request" {
  default = "10m"
}
variable "container_memoy_request" {
  default = "64Mi"
}

variable "kubeconfig_file_path" {}

variable "ca_cert_file_path" {}