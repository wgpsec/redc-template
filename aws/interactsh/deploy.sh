init(){

    terraform init

}

start_ecs(){

    terraform apply -var="domain=$1" -auto-approve
    ecs_ip=$(terraform output -json ecs_ip | jq '.' -r)

}

stop_ecs(){

    terraform destroy -var="domain=$1" -auto-approve

}

status_ecs(){

    terraform output

    echo "repo_link = https://github.com/projectdiscovery/interactsh"

}

CFAddRecords(){

    # 取 zone id
    zone_id=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?name=$3" \
        -H "X-Auth-Email: $1" \
        -H "X-Auth-Key: $2" \
        -H "Content-Type: application/json" | jq .result | jq -r '.[].id')

    if [ $zone_id ==  ] 2>> /dev/null
    then
        echo "zone_id not found"
        echo $zone_id
        zone_id=$(curl -X GET "https://api.cloudflare.com/client/v4/zones?name=$3" \
            -H "X-Auth-Email: $1" \
            -H "X-Auth-Key: $2" \
            -H "Content-Type: application/json" | jq .result | jq -r '.[].id')
    else
        echo "get zone_id"
    fi

    # 取 record id
    # 注意,有多个 A 记录的情况下这里会取到多个值,要确保目标域名只有 1 个 A 记录
    record_id=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=A" \
        -H "X-Auth-Email: $1" \
        -H "X-Auth-Key: $2" \
        -H "Content-Type: application/json" | jq .result | jq -r '.[].id')

    if [ $record_id ==  ] 2>> /dev/null
    then
        echo "record_id not found"
        echo $record_id
        record_id=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=A" \
            -H "X-Auth-Email: $1" \
            -H "X-Auth-Key: $2" \
            -H "Content-Type: application/json" | jq .result | jq -r '.[].id')
    else
        echo "get record_id"
    fi

    # 改 a 记录
    curl -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id" \
        -H "X-Auth-Email: $1" \
        -H "X-Auth-Key: $2" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"$4\",\"content\":\"$5\",\"ttl\":3600,\"proxied\":false}"

}

# bash deploy.sh -start dnslog.com
# bash deploy.sh -stop dnslog.com

case "$1" in
    -init)
        init
        ;;
    -start)
        start_ecs "a.$2"
        # 例如
        # A ns1 1.2.34
        # NS a ns1.dnslog.com
        CFAddRecords "你的 cf 邮箱" "你的 cf accesskey" $2 "ns1.$2" "$ecs_ip"
        ;;
    -stop)
        stop_ecs "a.$2"
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
