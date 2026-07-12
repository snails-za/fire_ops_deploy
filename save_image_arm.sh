#!/bin/bash

IMAGES=""

echo "pull images"
for img in $(grep -E '^[[:space:]]+image:' docker-compose.yml | awk '{print $2}' | uniq | sort);
do
  echo "pulling image: $img"
  docker pull $img
  IMAGES=${img}" "${IMAGES}
done

echo "saving images"
mkdir -p images
save_tar_path="images/fire_ops_all_image_arm.tar"
docker save -o ${save_tar_path} ${IMAGES} && gzip ${save_tar_path}
