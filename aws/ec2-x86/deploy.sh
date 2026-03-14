init(){

    terraform init

}

start_ecs(){

    terraform apply -auto-approve

}

stop_ecs(){

    terraform destroy -auto-approve

}

status_ecs(){

    terraform output

}

case "$1" in
    -init)
        init
        ;;
    -start)
        start_ecs
        ;;
    -stop)
        stop_ecs
        ;;
    -status)
        status_ecs
        ;;
    -h)
        echo -e "\033[1;34m使用 -init 初始化\033[0m"
        echo -e "\033[1;34m使用 -start 启动\033[0m"
        echo -e "\033[1;34m使用 -stop 关闭\033[0m"
        echo -e "\033[1;34m使用 -status 查询状态\033[0m"
        exit 1
        ;;
esac
