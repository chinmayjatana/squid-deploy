# TDP-TAP1.9-Bug-Bash

Welcome to the Bug Bash for TDP in TAP 1.9! This scenario will guide you through the process of testing TDP using an HTTP/HTTPS proxy.

## Getting started

## Prerequisites

- Make sure you have kubectl access to the TAP 1.9 cluster
- Make sure you have tanzu cli installed

## Steps

1. Clone the repository

```bash
git clone git@gitlab.eng.vmware.com:backstage-oss/tdp-tap1.9-bug-bash.git
```
- You will find the following files in the repository:
  - `deploy_squid_proxy.sh`: A script to deploy a squid proxy in the K8s cluster
  - `delete_squid_proxy.sh`: A script to delete the squid proxy from the K8s cluster
  - `squid.conf`: The configuration file for the squid proxy
  - `README.md`: The instructions for the bug bash
2. Change directory to the repository

```bash
cd tdp-tap1.9-bug-bash
```

3. Make all the scripts executable

```bash
chmod +x *.sh
```

4. Deploy a squid proxy in the K8s cluster

```bash
./deploy_squid_proxy.sh
```
5. Obtain the TDP pod name

```bash
kubectl get pods -n tap-gui
```

6. Get a shell in the TDP pod
```bash
kubectl exec -it <pod-name> -n tap-gui -- /bin/sh
```

7. Test that the TDP pod can access the internet

```bash
curl -x http://squid-proxy-service.proxy-ns.svc.cluster.local:3128 https://raw.githubusercontent.com/waldirmontoya25/tanzu-java-web-app/main/catalog/catalog-info.yaml
```

8. Extract the tap-values.yaml file
  
```bash
tanzu package installed get tap --values-file-output tap-values.yaml -n tap-install
```

9.  Configure TDP to use the squid proxy

```bash
tap_gui:
# The HTTP_PROXY environment variable is used to specify the proxy server for both HTTP and HTTPS requests.
  HTTP_PROXY: http://squid-proxy-service.proxy-ns.svc.cluster.local:3128
#  NO_PROXY: 'bar.com,baz.com' # The NO_PROXY environment variable is used to specify a comma-separated list of domain extensions for which the proxy server should not be used.
```

10. Update the TDP installation with the new configuration

```bash
tanzu package installed update tap -p tap.tanzu.vmware.com -n tap-install --values-file tap-values.yaml
```

11. Confirm that the TDP package is reconciling

```bash
tanzu kubernetes package installed list -A
```

12. Tail Squid proxy logs
```bash
kubectl exec -it <pod-name> -n proxy-ns -- /bin/sh
tail -f /var/log/squid/access.log
```

13. Test that TDP can access the internet using the squid proxy

- Register an entity located in github in TDP
- Deploy a workload using an accelerator located in github
- Test domain excemptions if possible. For example, you can add "acc-server.accelerator-system.svc.cluster.local" to NO_PROXY

14. Delete the squid proxy from the K8s cluster

```bash
./delete_squid_proxy.sh
``` 


## Thank you for participating in the Bug Bash!