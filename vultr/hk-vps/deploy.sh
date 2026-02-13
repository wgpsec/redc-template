start_vps(){
    # API key is read from VULTR_API_KEY environment variable
    terraform apply -auto-approve
}

stop_vps(){
    # API key is read from VULTR_API_KEY environment variable
    terraform destroy -auto-approve
}

status_vps(){
    terraform output -json vps_ip | jq '.' -r
    terraform output -json password | jq '.' -r
}

# 使用方法：
# 1. 通过 redc 配置文件（推荐）：编辑 ~/redc/config.yaml 添加 VULTR_API_KEY
# 2. 通过环境变量：export VULTR_API_KEY="your_api_key"
# 3. 直接在下面设置（不推荐）：export VULTR_API_KEY="your_api_key"
case "$1" in
    -start)
        start_vps
        ;;
    -stop)
        stop_vps
        ;;
    -status)
        status_vps
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
