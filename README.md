# Introduction

This repository is my PoC of how to use Kubernetes and host GraphQL mesh

The setup includes so far:

- `docker compose` to manage the setup
- Multi-master `K3s kubernetes with 2 agent nodes 
- `HAProxy`: Loadbalancing Kubernetes API


# Configuration

## Volume

This cluster uses local storage provider, which stores data inside `/local-volume` path. 

This path should be a volume mounted using docker compose. Check volume configuration of agent services:

```yml
    volumes:
      - /kubernetes/agent-1:/local-volume
```

the part `/kubernetes/agent-1` should be any location on your PC which can be used to store files from Kubernetes services.