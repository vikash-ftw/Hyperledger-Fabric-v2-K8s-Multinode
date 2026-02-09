# Hyperledger-Fabric-v2-K8s-Multinode

### Create the Kubernetes (K8s) cluster on new fresh machines
Document Guide - [Setup_Guide](https://docs.google.com/document/d/1IUcPG34ifwIFcejdEfs1xL9oHO6t1obZqt_dx9Z5dvE/edit?usp=sharing)

Minimum Recommended Nodes - `1 ControlPlane & 2 Worker Nodes`

### Reset your existing Kubernetes (K8s) Fabric Cluster
Follow the below steps sequentially for Cluster Cleanup.
- Removing existing K8s objects in running cluster:
    - Delete all deployments - 
        ```bash 
        kubectl delete deploy --all 
        ```
    - Delete all statefulset -
        ```bash 
        kubectl delete statefulset --all 
        ```
    - Delete all services - 
        ```bash 
        kubectl delete svc --all 
        ``` 
    - Delete all jobs -
        ```bash 
        kubectl delete jobs --all 
        ```
    - Delete fabric specific configmaps -
        ```bash 
        kubectl delete configmap builders-config ca-client-config 
        ```
- Now Remove the cluster and reset the K8s
    - First run on all worker nodes then in the end run on ControlPlane (master) node.
        ```bash 
        sudo kubeadm reset 
        ```
    - Remove the kubeconfig directory on ControlPlane -
        ```bash 
        rm -rf .kube/ 
        ```

