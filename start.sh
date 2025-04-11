#!/usr/bin/env bash

get_stack_status(){
  q=$(docker stack ls|cut -d ' ' -f 1)
  stack_name=$1
  is_stack_started=0
  for i in $q
  do
    if [ "$i" == "$stack_name" ];
    then
      is_stack_started=1
      break
    fi
  done
  return $is_stack_started
}

start_stack(){
  STACK_NAME=$1

  if [ $STACK_NAME == 'portainer' ]
  then
    docker stack deploy -c portainer-agent.yml $STACK_NAME
  elif [ $STACK_NAME == 'database' ]
  then
    docker stack deploy --with-registry-auth --prune -c database.yml $STACK_NAME
  elif [ $STACK_NAME == 'database_arm' ]
  then
    docker stack deploy --with-registry-auth --prune -c database-arm.yml $STACK_NAME
  elif [ $STACK_NAME == 'fastapi_demo' ]
  then
    docker stack deploy --with-registry-auth --prune -c docker-compose.yml $STACK_NAME
  elif [ $STACK_NAME == 'fastapi_demo_arm' ]
  then
    docker stack deploy --with-registry-auth --prune -c docker-compose-arm.yml $STACK_NAME
  fi
  sleep 3
  get_stack_status ${STACK_NAME}
  if [ $is_stack_started -eq 0 ];
  then
    sleep 10
    echo -e "\033[31m未找到名称为:[${stack_name}]的stack,请检查是否有容器未正常停止,确认后重试 \033[0m"
    exit -1
  fi
}

start(){
  STACK_NAME=$1

  print_style "====STACK NAME=${STACK_NAME}===" "info"
  print_style "====NETWORK NAME=${NETWORK}===" "info"

  docker stack rm ${STACK_NAME}
  sleep 10

  start_stack ${STACK_NAME}
  #check_deploy 5
}