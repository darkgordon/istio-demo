#!/bin/bash
#darkgordon

#Downloading istio and installing as default profile  
echo "Creating new dir for istio demos"
mkdir $HOME/istio
cd $HOME/istio
echo "Downloading istioctl "
echo "Recommended version 1.11.4"
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.11.4 TARGET_ARCH=x86_64 sh -
echo "Entering the dir"
cd istio-1.11.4
echo "Starting bin"
PATH=$PWD/bin:$PATH
echo "$PATH"
echo "Installing demo profile, read documentation for more profile references"
istioctl install --set profile=demo -y

echo "-------------Deploying kubernetes apps -V4.0-------------"
echo "waiting 10 to deploy de python apps "
sleep 10
cd $HOME/istio
echo "try to create ns"
kubectl create ns apps 
kubectl apply -f python_svc.yaml
for x in 1 2 3 4 5; do sleep 2 &&  kubectl get svc,pods -n apps ; done
echo "-------------Deploying kubernetes apps -V4.1-------------"
cd $HOME/istio
echo "try to create ns"
kubectl apply -f python_svc2.yaml
for x in 1 2 3 4 5; do sleep 2 &&  kubectl get svc,pods -n apps ; done

#Deploy prometheus metric server
echo "deploying prometheus demo deployment--required by kiali"
kubectl apply -f istio-1.11.4/samples/addons/prometheus.yaml


#Deploy of kali and virtual service
echo "DEPLOYING KIALI"
sleep 2
echo "Creating kiali deployment"
kubectl apply -f istio-1.11.4/samples/addons/kiali.yaml
echo "Review ingressGateway External ip"
kubectl get svc -n istio-system istio-ingressgateway
cd $HOME/istio
echo "Creating custom ingress gateway and virtualservice to kiali"
kubectl apply -f kiali_gateway_ingress.yaml
sleep 3


echo "Injecting istio sidecar to namespace apps "
kubectl label namespace apps istio-injection=enabled

echo "Delete all pods from the namespace apps, to inject the istio proxy"
kubectl delete --all pods -n apps

echo "Observe the pods have 2/2 containers, the envoy proxy "
for x in 1 2 3 4; do sleep 3 &&  kubectl get pods -n apps ; done
sleep 10
echo "Watch until ingressgateway external is on"
for x in 1 2 3 4; do sleep 5 && kubectl get svc -n istio-system istio-ingressgateway  ; done


###############
#Deploy python virtual services
kubectl apply -f python_svc_gateway.yaml
kubectl apply -f python_svc_gateway2.yaml






