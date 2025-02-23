#! /bin/bash

# kubectl label nodes <your-node-name> nvidia.com/gpu.relicas=<replicas-per-gpu>

kubectl apply -f time-slicing-config.yaml

kubectl patch clusterpolicy/cluster-policy \
    -n gpu-operator --type merge \
    -p '{"spec": {"devicePlugin": {"config": {"name": "time-slicing-config", "default": "any"}}}}'
