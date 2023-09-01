#!/bin/bash
projectName=centralized-graphlq-mesh
serversToStart=("server-1" "server-2" "server-3" "agent-1" "agent-2")

launchService(){
    docker compose -p $projectName up $1 -d
}

isServerConnected(){
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

startServer() {
    if (isServerConnected $1)
    then
        return;
    fi
    launchService $1

    while :
    do
        if (isServerConnected $1)
        then
            break;
        fi
        sleep 3;
    done
}


launchLoadBalancer;
for server in "${serversToStart[@]}"
do
    startServer $server;
done

kubectl --kubeconfig output/server-1/kubeconfig.yaml apply -k .