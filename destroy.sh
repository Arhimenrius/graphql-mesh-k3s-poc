#!/bin/sh

projectName=centralized-graphlq-mesh

docker compose -p $projectName down -v --rmi all