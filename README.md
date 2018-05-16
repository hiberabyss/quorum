# Deploy quorum via docker

* `cd ./docker-deploy`
* `./setup.sh`
* `docker-compose up -d`

# Create example contract

* `docker exec -it docker-deploy_node_1_1`
* `/nnodes/create_contract.sh`
* `loadScript("/nnodes/contract_pub.js")`

# Deploy via Kubernetes

* `cd ./helm/quorum`
* `helm install -n quorum .`

## Configuration

* Change file `./helm/quorum/values.yaml` `replicaCount: 5` to the number of nodes you want to start.
