#!/bin/bash
# Author            : Hongbo Liu <hbliu@freewheel.tv>
# Date              : 2018-05-10
# Last Modified Date: 2018-05-10
# Last Modified By  : Hongbo Liu <hbliu@freewheel.tv>

echo "var output = `solc --optimize --combined-json abi,bin,interface /nnodes/hello.sol 2>/dev/zero`" > /tmp/hello.js

geth attach /qdata/dd/geth.ipc

# loadScript("/nnodes/contract_pub.js")
