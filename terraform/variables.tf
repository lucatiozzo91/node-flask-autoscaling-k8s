variable "gcloud_region" { default = "europe-west3" }
variable "gcloud_zone" { default = "europe-west3-a" }
variable "gcloud_project" { default = "my-project" } #gcloud project id

variable "platform_name" { default = "cluster" } #cluster name

variable "cluster_master_auth_username" {default = "user"} #k8s auth username
variable "cluster_master_auth_password" {default = "pwd"} #k8s auth pwd

variable "cluster_node_machine_type" { default = "n1-highcpu-4" }
variable "cluster_node_initial_count" { default = 1 }
variable "cluster_node_pool_min_size" { default = 1 }
variable "cluster_node_pool_max_size" { default = 5 }


variable "pull_secret" {
  default = "my-secret"
}

variable "gitlab_project_id" {default = 10893233}
variable "registry_url" {default = ""}

#k8s pull secret data

variable "pull_secret_email" { default = "email@gmail.com"}
variable "pull_secret_password" { default = "pwd"}
variable "pull_secret_username" {default = "email"}

#gcloud static ip name for ingress
variable "static_ip_name" { default = "ingress-ip" }