#!/bin/bash
# Author            : Hongbo Liu <hbliu@freewheel.tv>
# Date              : 2018-05-16
# Last Modified Date: 2018-05-16
# Last Modified By  : Hongbo Liu <hbliu@freewheel.tv>

(cd ../../noscript-docker && docker build -t hbliu/quorum-k8s:latest . && docker push hbliu/quorum-k8s:latest)

helm upgrade quorum . --recreate-pods
