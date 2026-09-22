#!/usr/bin/env bash
set -e

kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/headlamp/main/kubernetes-headlamp.yaml
kubectl -n kube-system create serviceaccount headlamp-admin
kubectl create clusterrolebinding headlamp-admin --serviceaccount=kube-system:headlamp-admin --clusterrole=cluster-admin
kubectl patch -n kube-system svc headlamp -p '{"spec":{"type":"NodePort","ports":[{"port":80,"nodePort":30000}]}}'
echo
echo "Your ID-Token for Headlamp:"
kubectl create token headlamp-admin -n kube-system
echo
echo "Waiting for deployment..."
sleep 5
echo "Headlamp deployment information:"
kubectl get -n kube-system deployment headlamp
kubectl get -n kube-system pods -l k8s-app=headlamp
kubectl get -n kube-system service headlamp