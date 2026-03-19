## Hyperledger Fabric K8s Multinode Setup using Local Persistence and NFS (Combined)

**Note:** *Guide for 1 Control Plane and 2 Worker Nodes - Total 3 VMs*
- *Here any one of the worker can also act as NFS node.*

### Set up the NFS Node
On the NFS node setup the NFS server on a directory that be used as shared resource -
```bash
sudo apt update
sudo apt install nfs-kernel-server
sudo mkdir -p /mnt/shared_NFS
sudo chown -R nobody:nogroup /mnt/shared_NFS/
sudo chmod 777 /mnt/shared_NFS/
echo "/mnt/shared_NFS *(rw,sync,no_subtree_check,insecure)" | sudo tee -a /etc/exports
sudo exportfs -a
sudo systemctl restart nfs-kernel-server
```
Create a sharing directory on NFS at `/mnt` with name `shared_NFS`
```bash
sudo mkdir /mnt/shared_NFS
```
Clone the repo and copy contents meant for NFS purpose from the repo -
```bash
git clone https://github.com/vikash-ftw/Hyperledger-Fabric-v2-K8s-Multinode.git

cp -r Hyperledger-Fabric-v2-K8s-Multinode/shared_NFS/* /mnt/shared_NFS/
```

### Set up the Worker Nodes

On the worker we need to create directory that will be used for local persistence, so creating a directory - 
```bash
sudo mkdir /mnt/fabricNetworkFiles
```

### Creating Local Persistence and its claims for NFS and Worker Nodes

#### On Control Plane Node
First check if there are existing Persistent Volume(PV) and Persistent Volume Claims(PVC) present in k8s cluster

```bash
kubectl get pv
kubectl get pvc
```
Remove any conflicting or those are not required from the cluster.

Go to main control plane directory -
```bash
cd Fabric_K8s_ControlPlane
```
**Note:** Now after applying all the changes below keep checking pods using `kubectl get pods`

- Apply yaml files in `Fabric_K8s_ControlPlane/NFS` directory that consists of a PV and PVC files for NFS

**Note:** Edit the `<NFS NODE IP>` placeholder flag in `PV_nfs.yaml`

```bash
kubectl apply -f NFS
```

**Note:** Edit the worker machine name to properly apply PV and PVC
- Run this command to get worker machine labels as per your machine hostnames
```bash
kubectl get nodes --show-labels
```
From the above command output copy the `kubernetes.io/hostname` value for your specific machine
then make changes in `LPV_worker1.yaml` and `LPV_worker1.yaml`.
- Changes will be made here in above yaml files :
```yaml
- matchExpressions:
    - key: kubernetes.io/hostname
        operator: In
        values:
        - worker1  # Change the name here
```
- Now apply for Local Workers
```bash
kubectl apply -f Local-Persistence
```

- Now check PV and PVC again :
```bash
kubectl get pv
kubectl get pvc
```

### Deploying CA Service
Deploy the CA Authority service for orderer and org1
```bash
kubectl apply -f CA
```

### Generate Certificates
Now generate the certificates from CA service for orderer and peer organizations 
```bash
kubectl apply -f Certificates
```

### Create Artifacts
Create the artifacts for system genesis block and channel
```bash
kubectl apply -f Artifacts
```

### Start our Orderers
Create the Orderers using Statefulset object of k8s
```bash
# for orderers scheduled only for worker1
kubectl apply -f Orderers/statefulSets_worker1

# for orderers scheduled only for worker2
kubectl apply -f Orderers/statefulSets_worker2
```

### Setup ConfigMap
Now we apply the configurations related to Peers using ConfigMap 
```bash
kubectl apply -f Configmaps
```

### Start our Peers
Create the Peers using Statefulset Object
```bash
# for peers scheduled only for worker1
kubectl apply -f Peers/statefulSets_worker1

# for peers scheduled only for worker2
kubectl apply -f Peers/statefulSets_worker2
```
Now create the Peer's CLI pods to run our peer specific commands later.
```bash
kubectl apply -f Peers/peers_Cli_NFS
```

### Create Channel block file using Peer CLI
Go inside the Peer CLI pod then follow the commands from `Peer-CLI-Commands.md` file to create the channel block file -

```bash
# To go inside the Peer CLI pod
kubectl exec -it <Peer_CLI_Pod_ID> -- /bin/bash
```

### Chaincode Lifecycle

#### Chaincode Packaging (Automatically via Job)
As per you need you can go with any chaincode either `node` or `go`.
```bash
# for Node chaincode
kubectl apply -f Chaincode-Deployment/package_node_chaincode_job.yaml

# for Go chaincode
kubectl apply -f Chaincode-Deployment/package_go_chaincode_job.yaml
```

#### Chaincode install
Go inside the Peer CLI again and follow the Chaincode Install process from `Peer-CLI-Commands.md` file.

#### Chaincode External Deployment
Go to `Chaincode-Deployment` directory
- Now you must have a chaincode `packageID` with you. Use this packageID to edit the chaincode deployment files of node and go.

- Edit the `node-chaincode-deploy.yaml` or `go-chaincode-deploy.yaml`
- Change this - 
```yaml
env:
  - name: CORE_CHAINCODE_ID
    value: smartcontract-node:<CC_deployment_token>   # Paste PackageID here
```
Now after changes apply these changes for Node or Go chaincode
```bash
# For node chaincode
kubectl apply -f Chaincode-Deployment/node

# For go chaincode
kubectl apply -f Chaincode-Deployment/go
```
#### Chaincode Approve then Commit
Go inside the Peer CLI again and follow the Chaincode Approve and further process from `Peer-CLI-Commands.md` file.

### CCP Generation
Go to NFS node and then NFS directory - `/mnt/shared_NFS`

```bash
./scripts/ccp-generate.sh
```
### SDK Deployment
Final Stage is SDK deployment
- Edit the `chaincode-name` in the file at `SDK-App/k8s/sdk-configmap.yaml`
- Edit the below placeholder depending on your smartcontract language.
```yaml
CHAINCODE_NAME: <Chaincode-Name>  # smartcontract-node or smartcontract-go
```
After this change then apply sdk -
```bash
kubectl apply -f SDK-App/k8s
```