//output "client_certificate" {
//  value = "${module.cluster.client_certificate}"
//}
//
//output "client_key" {
//  value = "${module.cluster.client_key}"
//}
//
//output "cluster_ca_certificate" {
//  value = "${module.cluster.cluster_ca_certificate}"
//}


output "cluster_endpoint" {
  value = "${module.cluster.cluster_endpoint}"
}

output "public_loadbalancer_ip_address_value" {
  value = "${module.network.ingress-ip}"
}