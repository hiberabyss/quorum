# Deploy quorum via docker

* `cd ./docker-deploy`
* `./setup.sh`
* `docker-compose up -d`

# Create example contract

* `docker exec -it docker-deploy_node_1_1`
* `/nnodes/create_contract.sh`
* `loadScript("/nnodes/contract_pub.js")`
