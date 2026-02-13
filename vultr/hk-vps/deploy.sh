start_vps(){

    terraform apply -var="VULTR_API_KEY=$1" -auto-approve

}

stop_vps(){

    terraform destroy -var="VULTR_API_KEY=$1" -auto-approve

}

status_vps(){

    terraform output -json vps_ip | jq '.' -r
    terraform output -json password | jq '.' -r

}

# 这里 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 要替换成 vultr 的 api kye
case "$1" in
    -start)
        start_vps "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        ;;
    -stop)
        stop_vps "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        ;;
    -status)
        status_vps "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
        ;;
    -debug)
        debugx
        ;;
    -h)
        echo -e "\033[1;34m使用 -start 启动\033[0m"
        echo -e "\033[1;34m使用 -stop 关闭\033[0m"
        echo -e "\033[1;34m使用 -status 查询状态\033[0m"
        exit 1
        ;;
esac
