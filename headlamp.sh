#!/usr/bin/env bash
set -e

kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/headlamp/main/kubernetes-headlamp.yaml
kubectl -n kube-system create serviceaccount headlamp-admin
kubectl create clusterrolebinding headlamp-admin --serviceaccount=kube-system:headlamp-admin --clusterrole=cluster-admin
kubectl patch -n kube-system svc headlamp -p '{"spec":{"type":"NodePort","ports":[{"port":80,"nodePort":30000}]}}'
kubectl create token headlamp-admin -n kube-system
sleep 2
kubectl get -n kube-system svc headlamp