#!/bin/bash
#darkgordon
#Before testing with A/B or canary load balancing, first we must create a common server with the versions 4.0 and version 4.1
#We must label the templates then create a custom service that point both deployments 
echo "Patching the deployments with a new common label"
cat << EOF >> owner.yaml
spec:
  template: 
    metadata:
      labels:
        owner: darkgordon
EOF
echo "patching deployment with common label owner=darkgordon"
kubectl patch deployment pyhton-deployment1-test --patch-file owner.yaml -n apps
kubectl patch deployment pyhton-deployment2-test --patch-file owner.yaml -n apps
rm owner.yaml
kubectl get deployments -n apps -o=custom-columns=DEPLOYMENT_NAME:.metadata.name,OWNER:.spec.template.metadata.labels.owner
###########################################################################################################################
sleep 10
echo "------------ADDING VERSION LABEL TO BOTH DEPLOYMENTS------------"
echo "First, we must label our deployments with v4.0 and v4.1"
echo "---V4.0---"
echo "Saving v4.0 patch"
cat << EOF >> v4.0.yaml
spec:
  template: 
    metadata:
      labels:
        version: "v40"
EOF
echo "---V4.1--"
echo "Saving v4.1 patch"
sleep 3
cat << EOF >> v4.1.yaml
spec:
  template: 
    metadata:
      labels:
        version: "v41"
EOF
echo "patching deployment1"
kubectl patch deployment pyhton-deployment1-test --patch-file v4.0.yaml -n apps
echo "patching deployment2"
kubectl patch deployment pyhton-deployment2-test --patch-file v4.1.yaml -n apps
echo "deliting patches files"
rm v4.0.yaml
rm v4.1.yaml
echo "Review patched deployments"
kubectl get deployments -n apps -o=custom-columns=DEPLOYMENT_NAME:.metadata.name,TEMPLATE_PATCH:.spec.template.metadata.labels.version,OWNER:.spec.template.metadata.labels.owner
sleep 5
echo "waiting 10 seconds"
sleep 10
#Creating a new service that reference both deployments with the common label owner=dbayala
#This service will be used to create a custom gateway and virtualservice
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: python-service-deployment
  namespace: apps
spec:
  selector:
    owner: darkgordon
  ports:
    - name: python-port
      port: 5003
      targetPort: 5003
  type: ClusterIP
EOF
kubectl get svc python-service-deployment -n apps 
sleep 5
kubectl get endpoints python-service-deployment -n apps 
sleep 10
#Creating a new custom gateway and virtualService 
echo "Creating custom gateway for the new service"
cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: general-python-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway 
  servers:
  - port:
      number: 80
      name: http-python
      protocol: HTTP
    hosts:
    - "*"
EOF
echo "Creation of custom virtualservice for the A/B Canary test"
kubectl apply -f python_canary.yaml




