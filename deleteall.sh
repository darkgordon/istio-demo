#!/bin/bash
#David Benjamin Ayala Giralt
cd istio-1.11.4
PATH=$PWD/bin:$PATH
echo $PATH | grep istio
sleep 5
istioctl manifest generate --set profile=demo | kubectl delete --ignore-not-found=true -f -
istioctl tag remove apps
kubectl delete namespace istio-system
kubectl delete namespace apps
