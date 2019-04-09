output "cluster_name" {
  value = "${google_container_cluster.primary.name}"
}

output "cluster_endpoint" {
  value = "${google_container_cluster.primary.endpoint}"
}

output "client_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
}

output "tiller_account_name" {
  value = "${kubernetes_service_account.tiller.metadata.0.name}"
}

output "tiller_account_namespace" {
  value = "${kubernetes_service_account.tiller.metadata.0.namespace}"
}