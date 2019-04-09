#!/usr/bin/env bash
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.6/deploy/manifests/00-crds.yaml
kubectl label namespace default certmanager.k8s.io/disable-validation="true"
helm install --name cert-manager --namespace default stable/cert-manager
kubectl apply -f issuer.yaml
