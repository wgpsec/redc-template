check_input(){
    if [ $1 ==  ] 2>> /tmp/redc_error.log
    then
        echo "Use the default configuration"
        base64_command=$(cat nps.conf | base64)
        echo $base64_command
    else
        echo "Using custom configurations"
        base64_command=$1
        echo $base64_command
    fi
}

init(){

    terraform init

}

start_ecs_nps(){

    terraform apply -var="base64_command=$base64_command" -auto-approve

}

stop_ecs_nps(){

    terraform destroy -var="base64_command=$base64_command" -auto-approve

}

status_ecs_nps(){

    terraform output
    echo "nps_port : 8080"
    echo "nps_user : redone"
    echo "nps_pass : 1!2A3d4v5s6e"

}

case "$1" in
    -init)
        init
        ;;
    -start)
        check_input "$2"
        start_ecs_nps
        ;;
    -stop)
        check_input "$2"
        stop_ecs_nps
        ;;
    -status)
        status_ecs_nps
        ;;
    -h)
        echo -e "\033[1;34m使用 -init 初始化\033[0m"
        echo -e "\033[1;34m使用 -start 启动\033[0m"
        echo -e "\033[1;34m使用 -stop 关闭\033[0m"
        echo -e "\033[1;34m使用 -status 查询状态\033[0m"
        exit 1
        ;;
esac
