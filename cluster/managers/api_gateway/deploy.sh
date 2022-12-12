#!/bin/bash

KEY_PATH=../../../keys/us-east-2-oseas.pem

chmod 400 $KEY_PATH
source .env
if [ "$1" == "setup" ]; then
  ssh -i $KEY_PATH "${HOSTNAME}" "$(cat scripts/env_setup.sh)"
elif [ "$1" == "join" ]; then
  ssh -i $KEY_PATH "${HOSTNAME}" "$(cat scripts/swarm_join.sh)"
elif [ "$1" == "update" ]; then
  ssh -i $KEY_PATH "${HOSTNAME}" "$(cat scripts/update_stack.sh)"
elif [ "$1" == "create" ]; then
  ssh -i $KEY_PATH "${HOSTNAME}" "$(cat scripts/create_stack.sh)"
else
  echo "Empty Command for service - ${SERVICE_NAME}"
fi
