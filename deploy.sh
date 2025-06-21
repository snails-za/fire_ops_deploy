source ./start.sh

network='fire_ops-network'
export NETWORK='fire_ops-network'

mkdir -p data/elasticsearch/data
mkdir -p data/redis/data
mkdir -p data/postgres/data

main() {
  parse_params "$@"
  exec_by_params "$@"
}

print_style () {

    if [ "$2" == "info" ] ; then
        COLOR="96m";
    elif [ "$2" == "success" ] ; then
        COLOR="92m";
    elif [ "$2" == "warning" ] ; then
        COLOR="93m";
    elif [ "$2" == "error" ] ; then
        COLOR="91m";
    else #default color
        COLOR="0m";
    fi

    STARTCOLOR="\e[$COLOR";
    ENDCOLOR="\e[0m";

    printf "$STARTCOLOR%b$ENDCOLOR" "$1\n";
}

parse_params() {
 for arg in "$@";
 do
   case "$arg" in
    -h|--help)
      usage
      exit 0
      ;;
    -d|--deploy)
      ;;
    --service*)
      service_name=`echo $arg | awk -F '=' '{print $2}'`
      ;;
    *)
      ;;
  esac
 done
}

exec_by_params() {
 for arg in "$@";
 do
   case "$arg" in
    -d|--deploy)
      if [  $service_name ]
      then
        checkNetwork
        start $service_name
      else
        checkNetwork
        start portainer
        start database
        start fire_ops
      fi
      ;;
  esac
 done
}

checkNetwork(){
  docker_netowrk_check=`docker network ls | grep -w $network | wc -l`
  if [ $docker_netowrk_check -eq 1 ]
  then
      print_style "检测到网络 $network已创建" "warning"
      export NETWORK=$network
  else
    print_style "=====创建dokcer $network  网络=====" "info"
    docker network create --driver overlay --attachable  $network
    print_style "网络创建成功\n"  "success"
    export NETWORK=$network
  fi
}



main "$@" || exit 1