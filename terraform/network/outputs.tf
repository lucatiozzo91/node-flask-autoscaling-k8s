
output "ingress-ip" {
  value = "${google_compute_address.static_ip.address}"
}