### Prometheus and Grafana Setup

- Install helm (if installed check version)
```bash
helm version
```
- If not installed then install helm - 
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```
- Add Prometheus Helm Repo
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# now update helm repo
helm repo update
```

- Edit the Configs for Grafana Login credentials: Edit the `grafana-configs.yaml` file and replace `admin-password: <REPLACE_ME>` with your own password.

- Apply all the Prometheus and Grafana related configs in this `Grafana` directory: like svc, configMaps, secrets and service-monitor
```bash
kubectl apply -f .
```

- Now install Prometheus + Grafana Stack: install `kube-prometheus-stack`
```bash
helm install monitoring prometheus-community/kube-prometheus-stack
```
- Update the Grafana credentials for admin
```bash
# update admin default password to the password you set in grafana-configs.yaml secrets
helm upgrade monitoring prometheus-community/kube-prometheus-stack --set grafana.admin.existingSecret=grafana-secret

# delete the grafana pod to reflect changes in new pod
kubectl delete pod -l app.kubernetes.io/name=grafana
```
- Open Grafana Dashboard
```
http://<your_IP>:32000
```

