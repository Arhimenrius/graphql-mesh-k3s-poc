#!/bin/bash
projectName=centralized-graphlq-mesh
nodesToStart=("server-1" "server-2" "server-3" "agent-1" "agent-2")

launchService(){
    docker compose -p $projectName --compatibility up $1 -d
}

isNodeConnected(){
    kubectl --kubeconfig output/server-1/kubeconfig.yaml get nodes | grep "$1" | grep "Ready";
}

isLoadBalancerDown(){
    kubectl --kubeconfig output/server-1/kubeconfig.yaml get nodes 2>&1 >/dev/null | grep "right host or port"
}

launchLoadBalancer(){
    if (isLoadBalancerDown)
    then
        launchService load-balancer;
        sleep 2;
    fi
}

startNodes() {
    echo "Check if node $1 is already connected"
    if (isNodeConnected $1)
    then
        echo "Node $1 is already connected"
        return;
    fi

    echo "Launching node $1"
    launchService $1

    while :
    do
        echo "Check if node $1 is already connected"
        if (isNodeConnected $1)
        then
            break;
        fi
        echo "Retry to connect"
        sleep 3;
    done
}


launchService etcd;
launchLoadBalancer;
for node in "${nodesToStart[@]}"
do
    startNodes $node;
done

kubectl --kubeconfig output/server-1/kubeconfig.yaml apply -k .