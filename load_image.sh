#!/bin/bash

DEFAULT_TAR_GZ_FILE="images/fastapi_demo_all_image.tar.gz"

TAR_GZ_FILE=`echo $1`
if [ "${TAR_GZ_FILE}" == "" ];then
   TAR_GZ_FILE=${DEFAULT_TAR_GZ_FILE}
fi
echo "loading ${TAR_GZ_FILE}"
docker load -i ${TAR_GZ_FILE}