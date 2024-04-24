#!/bin/bash

# Define variables
DEPLOYMENT_NAME=squid-proxy
SERVICE_NAME=squid-proxy-service
NAMESPACE=proxy-ns
CONFIG_NAME=squid-config
CONFIG_FILE=squid.conf

if  [[ "$DISTRIBUTION" == "Openshift" ]] || [[ "$DISTRIBUTION" == "TKGM" ]] || [[ "$DISTRIBUTION" == "TKGS" ]] || [[ "$DISTRIBUTION" == *"TKGI"* ]]; then
  SQUID_IMAGE="harbor-repo.vmware.com/dockerhub-proxy-cache/sameersbn/squid:3.5.27-2"
else
  SQUID_IMAGE="sameersbn/squid:3.5.27-2"
fi

# Create Namespace
kubectl create ns $NAMESPACE

# Create ConfigMap from custom Squid configuration
kubectl create configmap $CONFIG_NAME --from-file=$CONFIG_FILE -n $NAMESPACE

# Create Squid Deployment with custom config
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $DEPLOYMENT_NAME
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: squid
  template:
    metadata:
      labels:
        app: squid
    spec:
      containers:
      - name: squid
        image: $SQUID_IMAGE
        ports:
        - containerPort: 3128
        volumeMounts:
        - name: squid-config-volume
          mountPath: /etc/squid/squid.conf
          subPath: squid.conf
      volumes:
      - name: squid-config-volume
        configMap:
          name: $CONFIG_NAME
EOF

# Create Squid Service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: $SERVICE_NAME
  namespace: $NAMESPACE
spec:
  ports:
  - port: 3128
    targetPort: 3128
  selector:
    app: squid
EOF

echo "Waiting for 10 sec for squid pod to come up and 2 min for squid pod to be running"
sleep 10
kubectl wait --for=condition=ready --timeout=120s pod -l app=squid -n $NAMESPACE
echo "Squid Proxy Deployment Completed. Use DNS name: ${SERVICE_NAME}.${NAMESPACE}.svc.cluster.local:3128"
