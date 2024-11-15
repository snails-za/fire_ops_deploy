#!/bin/bash

IMAGES=""

echo "pull images"
for img in $(cat *.yml | grep image: | awk '{print $2}' | uniq | sort);
do
  echo "pulling image: $img"
  docker pull $img
  IMAGES=${img}" "${IMAGES}
done

echo "saving images"
mkdir -p images
save_tar_path="images/fastapi_demo_all_image.tar"
docker save -o ${save_tar_path} ${IMAGES} && gzip ${save_tar_path}