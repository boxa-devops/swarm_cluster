source ./.env
sudo docker service update --image "${IMAGE}" "traefik_${SERVICE_NAME}"
