#!/usr/bin/env bash
helm install --name nginx-ingress stable/nginx-ingress --set rbac.create=true