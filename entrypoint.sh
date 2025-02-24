#!/bin/bash

# Set CUDA_VISIBLE_DEVICES based on available GPUs
export CUDA_VISIBLE_DEVICES=$(seq -s ',' 0 $(($(nvidia-smi -L | wc -l) - 1)))
export VLLM_CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES

# Setup SSH if PUBLIC_KEY is provided
if [ ! -z "$PUBLIC_KEY" ]; then
    echo "$PUBLIC_KEY" >> /root/.ssh/authorized_keys
    chmod 700 /root/.ssh/authorized_keys
    service ssh start
fi

# Keep container running
if [ "$1" = "bash" ]; then
    sleep infinity
else
    exec "$@"
fi
