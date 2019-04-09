provider kubernetes {
  host = "https://${var.cluster_endpoint}"
  cluster_ca_certificate = "${base64decode(var.cluster_ca_certificate)}"
  client_certificate = "${base64decode(var.cluster_client_certificate)}"
  client_key = "${base64decode(var.cluster_client_key)}"

  username = "${var.cluster_master_auth_username}"
  password = "${var.cluster_master_auth_password}"

}

provider "helm" {
  install_tiller = true
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.11.0"
  service_account = "${var.tiller_account_name}"
  namespace = "${var.tiller_account_namespace}"

  kubernetes {
    host = "https://${var.cluster_endpoint}"
    cluster_ca_certificate = "${base64decode(var.cluster_ca_certificate)}"
    client_certificate = "${base64decode(var.cluster_client_certificate)}"
    client_key = "${base64decode(var.cluster_client_key)}"

    username = "${var.cluster_master_auth_username}"
    password = "${var.cluster_master_auth_password}"

  }
}

resource "null_resource" "cert-manager-CRDs" {


  provisioner "local-exec" {
    command = "kubectl apply  --kubeconfig=${var.kubeconfig_file_path}  --server=https://${var.cluster_endpoint} --certificate-authority=${var.ca_cert_file_path} --token=${var.cluster_access_tokern} -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml"
  }
}
resource "null_resource" "cert-manager-labels" {

  provisioner "local-exec" {
    command = "kubectl label  --kubeconfig=${var.kubeconfig_file_path}  --server=https://${var.cluster_endpoint} --certificate-authority=${var.ca_cert_file_path} --token=${var.cluster_access_tokern} namespace default certmanager.k8s.io/disable-validation=true"
  }
}
resource "helm_release" "cert-manager" {

  depends_on = [
    "null_resource.cert-manager-CRDs",
    "null_resource.cert-manager-labels"]

  name = "cert-manager"
  chart = "stable/cert-manager"
  namespace = "default"

}

resource "null_resource" "cert-manager-issuer" {
  depends_on = [
    "helm_release.cert-manager"
  ]


  provisioner "local-exec" {
    command = "kubectl apply  --kubeconfig=${var.kubeconfig_file_path}  --server=https://${var.cluster_endpoint} --certificate-authority=${var.ca_cert_file_path} --token=${var.cluster_access_tokern} -f ../ingress/letsencrypt/issuer.yaml"
  }
}


resource "helm_release" "nginx-ingress" {

  name = "nginx-ingress"
  chart = "stable/nginx-ingress"
  namespace = "default"

  set {
    name = "rbac.create"
    value = "true"
  }

  set {
    name = "controller.service.loadBalancerIP"
    value = "${var.ingress_ip}"
  }
}




resource "null_resource" "ingress" {

  triggers {
    ingress = "${file("../ingress/ingress.yaml")}"
  }

  depends_on = [
    "helm_release.cert-manager"]


  provisioner "local-exec" {
    command = "kubectl apply --kubeconfig=${var.kubeconfig_file_path}  --server=https://${var.cluster_endpoint} --certificate-authority=${var.ca_cert_file_path} --token=${var.cluster_access_tokern} -f ../ingress/ingress.yaml"
  }
}
