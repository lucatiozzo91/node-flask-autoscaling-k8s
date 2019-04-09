#!/usr/bin/env bash
helm install -f values.yaml --namespace=default --name=monitoring stable/prometheus-operator