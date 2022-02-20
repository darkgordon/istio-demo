#!/bin/bash
#David Benjamin Ayala Giralt
echo "Creating kubernetes cluster"
export KOPS_STATE_STORE=s3://se-benjamin/kops
kops create -f /mnt/c/Users/darkg/Desktop/Material/shareofknowledge/kops/secondtest/clusteroriginal.yaml 
kops update cluster --name davidayala.k8s.local --yes
kops export kubeconfig --admin
kops validate cluster --wait 10m --count 3
echo "K8S IS READY"
kubectl get nodes 
kubectl cluster-info