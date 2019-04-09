resource "google_compute_address" "static_ip" {
  name = "${var.static_ip_name}"
  region = "${var.cluster_region}"
}
