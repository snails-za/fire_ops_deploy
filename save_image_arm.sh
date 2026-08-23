#!/bin/bash

IMAGES=""

echo "pull images"
for img in $(docker compose -f docker-compose.yml -f docker-compose-arm.yml config --images 2>/dev/null | sort -u);
do
  echo "pulling image: $img"
  docker pull $img
  IMAGES=${img}" "${IMAGES}
done

echo "saving images"
mkdir -p images
save_tar_path="images/fire_ops_all_image_arm.tar"
docker save -o ${save_tar_path} ${IMAGES} && gzip ${save_tar_path}
