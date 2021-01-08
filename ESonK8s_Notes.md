## vagrant

https://www.vagrantup.com/downloads

```
vagrant --version
>> Vagrant 2.2.14
```

## create cluster

```sh
brew install virtualbox

git clone https://github.com/amliuyong/elastic-cloud-on-kubernetes-webinar

cd elastic-cloud-on-kubernetes-webinar-master/k8s_ubuntu

vagrant up --provider=virtualbox

```

## destroy vagrant
```
vagrant status
vagrant destroy

```

## ssh to Cluster
```
vagrant ssh kmaster
kubectl get nodes

kubectl describe node kmaster

kubectl describe node kworker1

```

# Setup a single ndoe ES cluster (ES, kibana and k8s dashboard)
```

// install ES
kubectl apply -f  http://download.elastic.co/downloads/eck/1.1.1/all-in-one.yaml

kubectl get ns
kubectl -n elastic-system get all

kubectl apply -f https://raw.githubusercontent.com/amliuyong/elastic-cloud-on-kubernetes-webinar/master/01_single-node-elasticsearch.yaml
# kubectl apply -f /vagrant/k8s/01_single-node-elasticsearch.yaml

kubectl apply -f https://raw.githubusercontent.com/amliuyong/elastic-cloud-on-kubernetes-webinar/master/02_kibana.yaml
# kubectl apply -f /vagrant/k8s/02_kibana.yaml

// wait for running
kubectl get pods


kubectl get secret

kubectl describe secret quickstart-es-elastic-user


PASSWORD=$(kubectl get secret quickstart-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')
echo $PASSWORD


kubectl get svc

>> quickstart-es-http        NodePort    10.96.50.161   <none>        9200:31920/TCP   3m56s

## below commands get same output
curl -u elastic:$PASSWORD -k https://localhost:31920
curl -u elastic:$PASSWORD -k https://10.96.50.161:9200

// get INTERNAL-IP
kubectl get nodes -o wide | egrep -o [0-9]+\\.[0-9]+\\.[0-9]+\\.[0-9]+ 

ip addr
```

## local matchine
```
echo $PASSWORD
curl -u "elastic:4f1TB4g2m4V707Y19OCndXKB"  -k https://172.42.42.100:31920

```
output:
```
yongliu@local:~$ curl -u "elastic:4f1TB4g2m4V707Y19OCndXKB"  -k https://172.42.42.100:31920
{
  "name" : "quickstart-es-default-0",
  "cluster_name" : "quickstart",
  "cluster_uuid" : "kzjLaPIVTAyw3vUE71d2Pg",
  "version" : {
    "number" : "7.6.2",
    "build_flavor" : "default",
    "build_type" : "docker",
    "build_hash" : "ef48eb35cf30adf4db14086e8aabd07ef6fb113f",
    "build_date" : "2020-03-26T06:34:37.794943Z",
    "build_snapshot" : false,
    "lucene_version" : "8.4.0",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```
```
chrome:

https://172.42.42.100:31560

```
### k8s dashboard (not ES dashboard)
```
cd /vagrant/k8s

kubectl apply -f 03_k8s_dashboard-not-safe-for-production.yaml

```

# Setup a single node ES  with `s3-repository` plugin
- 04_single_node_es_plugin_install.yaml
```
cd /vagrant/k8s

// delete old ES 
kubectl delete -f 01_single-node-elasticsearch.yaml

kubectl get pods

// create aws awsaccesskey

// kubectl delete secret awsaccesskey
// kubectl delete secret awssecretkey
kubectl create secret generic awsaccesskey --from-literal=AWS_ACCESS_KEY_ID=xxxxxxxx
kubectl create secret generic awssecretkey --from-literal=AWS_SECRET_ACCESS_KEY=xxxxxxx

kubectl get secret

kubectl get secret awsaccesskey -o go-template='{{.data.AWS_ACCESS_KEY_ID | base64decode}}'

kubectl get secret awssecretkey -o go-template='{{.data.AWS_SECRET_ACCESS_KEY | base64decode}}'

kubectl apply -f 04_single_node_es_plugin_install.yaml

```
### initContainers in 04_single_node_es_plugin_install.yaml
```yaml
initContainers:
            - name: install-plugins
              command:
                - sh
                - -c
                - |
                  bin/elasticsearch-plugin install --batch repository-s3
                  echo $AWS_ACCESS_KEY_ID | /usr/share/elasticsearch/bin/elasticsearch-keystore add --stdin s3.client.default.access_key
                  echo $AWS_SECRET_ACCESS_KEY | /usr/share/elasticsearch/bin/elasticsearch-keystore add --stdin s3.client.default.secret_key
```

### check the plugin
```
PASSWORD=$(kubectl get secret quickstart-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')
echo $PASSWORD

curl -XGET -u "elastic:$PASSWORD" -k https://localhost:31920/_cat/plugins

// kibana
https://172.42.42.100:31560/app/kibana#/dev_tools/console

```


# Setup a single node ES with local persistent-volume enabled
- 05_persistent-volume.yaml
- 06_es-with-persistent-volume-enabled.yaml
  
```
cd /vagrant/k8s

// delete old ES 
kubectl delete -f 04_single_node_es_plugin_install.yaml
kubectl delete -f 02_kibana.yaml
kubectl delete -f 03_k8s_dashboard-not-safe-for-production.yaml

=====================================================================

// create

kubectl apply -f 05_persistent-volume.yaml
kubectl get pv

kubectl apply -f 06_es-with-persistent-volume-enabled.yaml
kubectl get pvc

```

# Setup multi-nodes (2 nodes) ES cluster

 - 07-pv-for-multi-nodes.yaml
 - 08-multinode-es.yaml

```
will create:

2 PVs  --> ReadWriteOnce
2 Nodes -->  1 Pv allocated to 1 Node

=====================================================================
// clear Old ES

kubectl delete -f 06_es-with-persistent-volume-enabled.yaml
kubectl delete -f 05_persistent-volume.yaml

// create 2 PVs

kubectl apply -f 07-pv-for-multi-nodes.yaml
kubectl get pv
>>
NAME                CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
es-data-holder-01   5Gi        RWO            Retain           Available           manual                  5s
es-data-holder-02   5Gi        RWO            Retain           Available           manual                  5s

// create 2 nodes ES

kubectl apply -f 08-multinode-es.yaml
```

kubectl get pvc
```
NAME                                              STATUS   VOLUME              CAPACITY   ACCESS MODES   STORAGECLASS   AGE
elasticsearch-data-quickstart-es-data-nodes-0     Bound    es-data-holder-02   5Gi        RWO            manual         9s
elasticsearch-data-quickstart-es-master-nodes-0   Bound    es-data-holder-01   5Gi        RWO            manual         10s
```
```
// check nodes 

PASSWORD=$(kubectl get secret quickstart-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')

curl -u elastic:$PASSWORD -k https://localhost:31920/_cluster/health?pretty
curl -u elastic:$PASSWORD -k https://localhost:31920/_cat/nodes?v
```
```
ip             heap.percent ram.percent cpu load_1m load_5m load_15m node.role master name
192.168.77.135           15          78   4    0.85    0.68     0.42 dim       *      quickstart-es-master-nodes-0
192.168.41.137           25          96   4    0.15    0.36     0.40 di        -      quickstart-es-data-nodes-0

// note: node.role: dim/di
```
### hot/ warm architecture
 - node.attr.temp: hot  for master-nodes
 - node.attr.temp: warm  for data-nodes
  
```yaml
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: quickstart
spec:
  version: 7.6.2
  nodeSets:
    - name: master-nodes
      count: 1
      config:
        node.master: true
        node.data: true
        node.ml: false
        node.store.allow_mmap: false
        node.attr.temp: hot
      podTemplate:
        spec:
          containers:
            - name: elasticsearch
```

```

curl -u elastic:$PASSWORD -XPUT -k "https://localhost:31920/logs-01" -H 'Content-Type: application/json' -d '
{
    "settings": {
        "index.routing.allocation.require.temp": "warm"
    }
}'

curl -u elastic:$PASSWORD -XGET  -k "https://localhost:31920/logs-01/_settings"?pretty


curl -u elastic:$PASSWORD -XPUT -k "https://localhost:31920/logs-02" -H 'Content-Type: application/json' -d '
{
    "settings": {
        "index.routing.allocation.require.temp": "hot"
    }
}'

curl -u elastic:$PASSWORD -XGET  -k "https://localhost:31920/logs-02/_settings"?pretty


curl -u elastic:$PASSWORD -XGET  -k https://localhost:31920/_cat/shards/logs-01?v
>>
index   shard prirep state      docs store ip             node
logs-01 0     p      STARTED       0  230b 192.168.41.137 quickstart-es-data-nodes-0
logs-01 0     r      UNASSIGNED
--

curl -u elastic:$PASSWORD -XGET  -k https://localhost:31920/_cat/shards/logs-02?v
>>
index   shard prirep state      docs store ip             node
logs-02 0     p      STARTED       0  230b 192.168.77.135 quickstart-es-master-nodes-0
logs-02 0     r      UNASSIGNED
--

```
# Scaling out your nodes in ES cluster

- 09-two-node-es-cluster.yaml
- 09-four-node-es-cluster.yaml

```
// clear Old ES

kubectl delete -f 08-multinode-es.yaml
kubectl delete -f 07-pv-for-multi-nodes.yaml

// create ES cluster

kubectl apply -f 09-two-node-es-cluster.yaml

// Scaling node count - 2 master, 2 data

kubectl apply -f 09-four-node-es-cluster.yaml

kubectl get pods
>>
NAME                           READY   STATUS    RESTARTS   AGE
quickstart-es-data-nodes-0     1/1     Running   0          4m59s
quickstart-es-data-nodes-1     1/1     Running   0          2m22s
quickstart-es-master-nodes-0   1/1     Running   0          4m59s
quickstart-es-master-nodes-1   1/1     Running   0          2m22s

```


# Upgrade ES to new version

- 10-upgrade-four-node-es-cluster.yaml

```
// check current version
curl -u elastic:$PASSWORD -XGET  -k https://localhost:31920?pretty

// apply new version: 7.7.0 
kubectl apply -f  10-upgrade-four-node-es-cluster.yaml

PASSWORD=$(kubectl get secret quickstart-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')
echo $PASSWORD

// check new version
curl -u elastic:$PASSWORD -XGET  -k https://localhost:31920?pretty

```

# Final
- all-in-one.yaml
- 07-4-pvs-for-multi-nodes.yaml
- 09-multinode-es-with-2-data-nodes.yaml
- 10-multinode-es-upgrade-to-7.7.0.yaml
```
kubectl delete -f 10-upgrade-four-node-es-cluster.yaml
kubectl get pods

kubectl apply -f  http://download.elastic.co/downloads/eck/1.1.1/all-in-one.yaml

// create 4 nodes with PV
kubectl apply -f  07-4-pvs-for-multi-nodes.yaml
kubectl apply -f  09-multinode-es-with-2-data-nodes.yaml

// check PVC for the 4 nodes
kubectl get pvc
>> 
NAME                                              STATUS   VOLUME              CAPACITY   ACCESS MODES   STORAGECLASS   AGE
elasticsearch-data-quickstart-es-data-nodes-0     Bound    es-data-holder-04   5Gi        RWO            manual         18s
elasticsearch-data-quickstart-es-data-nodes-1     Bound    es-data-holder-01   5Gi        RWO            manual         18s
elasticsearch-data-quickstart-es-master-nodes-0   Bound    es-data-holder-02   5Gi        RWO            manual         18s
elasticsearch-data-quickstart-es-master-nodes-1   Bound    es-data-holder-03   5Gi        RWO            manual         18s


PASSWORD=$(kubectl get secret quickstart-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')
echo $PASSWORD

curl -u elastic:$PASSWORD -XGET  -k https://localhost:31920?pretty

curl -u elastic:$PASSWORD -XGET  -k https://localhost:31920/_cluster/health?pretty

// upgrade 

kubectl apply -f  10-multinode-es-upgrade-to-7.7.0.yaml

```

# Fix Bug
```
kubectl get events

vagrant status
vagrant reload
```



# Install Elastic Stack (EFK) Elastic, FluentD, Kibana
https://gitlab.com/nanuchi/efk-course-commands/-/blob/master/commands.md

##### install elastic search chart 
    helm repo add elastic https://Helm.elastic.co
    helm install elasticsearch elastic/elasticsearch -f values-linode.yaml

##### install Kibana chart
    helm install kibana elastic/kibana

##### access Kibana locally
    kubectl port-forward deployment/kibana-kibana 5601
    access: localhost:5601

##### install nginx-ingress controller
    helm repo add stable https://charts.helm.sh/stable 
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm install nginx-ingress ingress-nginx/ingress-nginx

###### NOTE
Repo has been deprecated - https://stackoverflow.com/a/57970816    
    
    helm repo add stable https://kubernetes-charts.storage.googleapis.com/ 

##### install Fluentd
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm install fluentd bitnami/fluentd


### Other useful commands

##### restart Fluentd deamonSet
    kubectl rollout restart daemonset/fluentd

##### restart elastic search statefulSet
    kubectl rollout restart statefulset/elasticsearch-master

##### install specific helm version
    helm install elasticsearch elastic/elasticsearch --version="7.9.0" -f values-linode.yaml
    helm install kibana elastic/kibana --version="7.9.0"
    helm install fluentd bitnami/fluentd --version="2.0.1"

    helm install nginx-ingress ingress-nginx/ingress-nginx --version="2.15.0"

##### install helm chart in a specific namespace (namespace must already exist)
    helm install elasticsearch elastic/elasticsearch -f values-linode.yaml -n elastic



# ElasticSearch - Fluentd - Kibana - on K8s cluster
https://github.com/amliuyong/Logging-in-K8s-EFK
