#!/bin/bash
# Author            : Hongbo Liu <hbliu@freewheel.tv>
# Date              : 2018-05-15
# Last Modified Date: 2018-05-15
# Last Modified By  : Hongbo Liu <hbliu@freewheel.tv>

set +e

env_file="env.sh"

init() {
    echo '[1] environment init'

    mkdir -p /qdata/{logs,keys,dd/geth}

    : > $env_file
    echo "IP=$(hostname -i)" >> $env_file

    bootnode -genkey /qdata/dd/nodekey -writeaddress
    node_id=$(bootnode -nodekeyhex $(cat /qdata/dd/nodekey) -writeaddress)

    echo "NODE_ID=$node_id" >> $env_file

    touch /qdata/passwords.txt
    account=$(geth --datadir=/qdata/dd --password /qdata/passwords.txt account new | cut -c 11-50)
    echo "ACCOUNT=$account" >> $env_file
    python -m SimpleHTTPServer 80 &
}

load_env_from_server() {
    local host=$1

    host_suffix=$(hostname -f)
    host_suffix=${host_suffix#*.}

    host=$host.$host_suffix

    set +e
    local i
    for (( i = 0; i < 60; i++ )); do
        if curl -s $host &> /dev/zero; then
            source <(curl -s $host/$env_file)
            return 0
        fi
        sleep 2
    done

    return -1
}

gen_static_nodes() {
    echo '[2] Creating Enodes and static-nodes.json.'

    local dest="/qdata/dd/static-nodes.json"
    ips=$1

    echo "[" > $dest
    local i
    for (( i = 0; i < node_number; i++ )); do
        load_env_from_server ${node_prefix}$i

        sep=`[[ $i -lt $((node_number -1)) ]] && echo ","`
        echo '  "enode://'$NODE_ID'@'$IP':30303?raftport=50400"'$sep >> $dest
    done
    echo "]" >> $dest
}

gen_genesis() {
    echo '[3] Creating Ether accounts and genesis.json.'
    local dest="/qdata/genesis.json"

cat > $dest <<EOF
{
  "alloc": {
EOF

local i
for (( i = 0; i < node_number; i++ )); do
    load_env_from_server "${node_prefix}$i"

    sep=`[[ $i -lt $((node_number-1)) ]] && echo ","`
    cat >> $dest <<EOF
    "${ACCOUNT}": {
      "balance": "1000000000000000000000000000"
    }${sep}
EOF

done

cat >> $dest <<EOF
  },
  "coinbase": "0x0000000000000000000000000000000000000000",
  "config": {
    "homesteadBlock": 0
  },
  "difficulty": "0x0",
  "extraData": "0x",
  "gasLimit": "0x2FEFD800",
  "mixhash": "0x00000000000000000000000000000000000000647572616c65787365646c6578",
  "nonce": "0x0",
  "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "timestamp": "0x00"
}
EOF
}

gen_tm_conf() {
    echo '[4] Create tm.conf.'

    local dest="/qdata/tm.conf"

    local i
    for (( i = 0; i < node_number; i++ )); do
        load_env_from_server ${node_prefix}$i

        sep=`[[ $i != 0 ]] && echo ","`
        nodelist=${nodelist}${sep}'"http://'${IP}':9000/"'
    done

cat > $dest << EOF
url = "http://$(hostname -i):9000/"
port = 9000
socket = "tm.ipc"
othernodes = [$nodelist]
publickeys = ["/qdata/keys/tm.pub"]
privatekeys = ["/qdata/keys/tm.key"]
workdir = "/qdata/constellation"
tls = "off"
EOF
}

gen_tm_keys() {
    echo '[4] Generate keys.'
    constellation-node --generatekeys=/qdata/keys/tm < /dev/null > /dev/null
    echo "Node Public Key: $(cat /qdata/keys/tm.pub)"
}

start_node() {
    # set -u
    # set -e

    ### Configuration Options
    TMCONF=/qdata/tm.conf

    GETH_ARGS="--datadir /qdata/dd --raft --rpc --rpcaddr 0.0.0.0 --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum --nodiscover --unlock 0 --password /qdata/passwords.txt"

    if [ ! -d /qdata/dd/geth/chaindata ]; then
        echo "[*] Mining Genesis block"
        /usr/local/bin/geth --datadir /qdata/dd init /qdata/genesis.json
    fi

    echo "[*] Starting Constellation node"
    nohup /usr/local/bin/constellation-node $TMCONF 2>> /qdata/logs/constellation.log &

    sleep 2

    echo "[*] Node Started..."
    PRIVATE_CONFIG=$TMCONF nohup /usr/local/bin/geth $GETH_ARGS 2>>/qdata/logs/geth.log
}

main() {
    node_prefix=${NODE_PREFIX-quorum-}
    node_number=${NODE_NUMBER-2}

    init
    gen_static_nodes
    gen_genesis
    gen_tm_conf
    gen_tm_keys
    start_node
    bash -c "sleep 1000000"
}

main $@
