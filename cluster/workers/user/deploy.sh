#!/bin/bash

KEY_PATH=../../../keys/us-east-2-oseas.pem
COMMANDS="setup connect init join leave update network create"
source .env
chmod 400 $KEY_PATH

if [ "$1" == "setup" ]; then
  ssh -i $KEY_PATH "${HOSTNAME}" "$(cat scripts/env_setup.sh)"
elif [ "$1" == "connect" ]; then
  ssh -i $KEY_PATH "${HOSTNAME}"
elif [ "$1" == "init" ]; then
  ssh -i $KEY_PATH "${HOSTNAME}" "sudo docker node update --label-add ${STACK}.${STACK}-certificates=true $(sudo docker info -f '{{.Swarm.NodeID}}')"
  ssh -i $KEY_PATH "${HOSTNAME}" "sudo docker swarm init --advertise-addr ${LEADER_HOST}:${LEADER_PORT}"
elif [ "$1" == "join" ]; then
  ssh -i $KEY_PATH "${HOSTNAME}" "sudo  docker swarm join --token ${SWARM_TOKEN} ${LEADER_HOST}:${LEADER_PORT}"
elif [ "$1" == "worker-token" ]; then
  ssh -i $KEY_PATH "${HOSTNAME}" "sudo docker swarm join-token --quiet worker"
elif [ "$1" == "manager-token" ]; then
  ssh -i $KEY_PATH "${HOSTNAME}" "sudo docker swarm join-token --quiet manager"
elif [ "$1" == "leave" ]; then
  ssh -i $KEY_PATH "${HOSTNAME}" "sudo docker swarm leave --force"
elif [ "$1" == "update" ]; then
  ssh -i $KEY_PATH "${HOSTNAME}" "$(cat scripts/image_upd.sh)"
elif [ "$1" == "network" ]; then
  ssh -i $KEY_PATH "${HOSTNAME}" "sudo docker network create --scope=swarm --driver=overlay ${PUBLIC_NETWORK}"
elif [ "$1" == "create" ]; then
  scp -i $KEY_PATH .env "${HOSTNAME}:.env"
  scp -i $KEY_PATH "${DEPLOY_FILEPATH}" "${HOSTNAME}:${SERVICE_NAME}-deploy.yaml"
  ssh -i $KEY_PATH "${HOSTNAME}" "env $(cat .env | xargs) envsubst < ./${SERVICE_NAME}-deploy.yaml | sudo docker stack deploy --compose-file - ${SERVICE_NAME} --with-registry-auth"
else
  echo "Empty Command for service - ${SERVICE_NAME}"
  echo "Available Commands"
  for word in $COMMANDS    # the variable needs to be unquoted to get "word splitting"
  do
    echo "  - $word"
  done
fi
