#!/bin/bash

# Define deployment, service, and namespace names
DEPLOYMENT_NAME=squid-proxy
SERVICE_NAME=squid-proxy-service
NAMESPACE=proxy-ns

# Delete the Squid Deployment
kubectl delete deployment $DEPLOYMENT_NAME --namespace $NAMESPACE

# Delete the Squid Service
kubectl delete service $SERVICE_NAME --namespace $NAMESPACE

# Delete the Namespace (this will remove all resources within the namespace)
kubectl delete ns $NAMESPACE

echo "Squid Proxy and all related resources have been deleted."
