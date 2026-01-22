# Load ss_port/ss_pass from terraform.tfvars in the current directory
load_tfvars(){
    # shellcheck source=/dev/null
    source "./terraform.tfvars"
}

load_tfvars

init(){

    terraform init && echo "init success" || { echo "init retry"; terraform init || exit 1; }

}

start_zone_ecs_ss_libev(){

    terraform apply -lock=false -var="node_count=$1" -auto-approve
    terraform output -json ecs_ip | jq '.[]' -r > temp_ip.txt

}

stop_zone_ecs_ss_libev(){

    terraform destroy -lock=false -var="node_count=$1" -auto-approve || { echo "destroy retry"; terraform init; terraform destroy -lock=false -var="node_count=$1" -auto-approve || exit 1; }

}

gen_zone_clash_config(){

    # 允许 ipv6 代理,和 aliyun 代理池不同
    part1="bWl4ZWQtcG9ydDogNjQyNzcKYWxsb3ctbGFuOiB0cnVlCmJpbmQtYWRkcmVzczogJyonCm1vZGU6IHJ1bGUKbG9nLWxldmVsOiBpbmZvCmlwdjY6IHRydWUKZXh0ZXJuYWwtY29udHJvbGxlcjogMTI3LjAuMC4xOjkwOTAKc2VjcmV0OiB0eHR0eHR4dDJzeHR4dHh0ZGR4dHh0MTExMTExMQpyb3V0aW5nLW1hcms6IDY2NjYKaG9zdHM6Cgpwcm9maWxlOgogIHN0b3JlLXNlbGVjdGVkOiBmYWxzZQogIHN0b3JlLWZha2UtaXA6IHRydWUKCmRuczoKICBlbmFibGU6IGZhbHNlCiAgbGlzdGVuOiAwLjAuMC4wOjUzCiAgaXB2NjogdHJ1ZQogIGRlZmF1bHQtbmFtZXNlcnZlcjoKICAgIC0gMjIzLjUuNS41CiAgICAtIDExOS4yOS4yOS4yOQogIGVuaGFuY2VkLW1vZGU6IGZha2UtaXAgIyBvciByZWRpci1ob3N0IChub3QgcmVjb21tZW5kZWQpCiAgZmFrZS1pcC1yYW5nZTogMTk4LjE4LjAuMS8xNiAjIEZha2UgSVAgYWRkcmVzc2VzIHBvb2wgQ0lEUgogIG5hbWVzZXJ2ZXI6CiAgICAtIDIyMy41LjUuNSAjIGRlZmF1bHQgdmFsdWUKICAgIC0gMTE5LjI5LjI5LjI5ICMgZGVmYXVsdCB2YWx1ZQogICAgLSB0bHM6Ly9kbnMucnVieWZpc2guY246ODUzICMgRE5TIG92ZXIgVExTCiAgICAtIGh0dHBzOi8vMS4xLjEuMS9kbnMtcXVlcnkgIyBETlMgb3ZlciBIVFRQUwogICAgLSBkaGNwOi8vZW4wICMgZG5zIGZyb20gZGhjcAogICAgIyAtICc4LjguOC44I2VuMCcKCnByb3hpZXM6Cg=="

    rm -rf temp_part2.txt
    rm -rf temp_part4.txt

    terraform output -json ecs_ip | jq '.[]' -r > temp_ip.txt

    while read -r line
    do
        echo "  - name: \"$line\"" >> temp_part2.txt
        echo '    type: ss' >> temp_part2.txt
        echo "    server: $line" >> temp_part2.txt
        echo "    port: $ss_port" >> temp_part2.txt
        echo '    cipher: chacha20-ietf-poly1305' >> temp_part2.txt
        echo "    password: \"$ss_pass\"" >> temp_part2.txt
        echo "" >> temp_part2.txt
    done < temp_ip.txt

    part2=$(cat temp_part2.txt | base64)

    part3="cHJveHktZ3JvdXBzOgogIC0gbmFtZTogInRlc3QiCiAgICB0eXBlOiBsb2FkLWJhbGFuY2UKICAgIHByb3hpZXM6Cg=="

    while read -r line
    do
        echo "      - $line" >> temp_part4.txt
    done < temp_ip.txt

    part4=$(cat temp_part4.txt | base64)

    part5="ICAgIHVybDogJ2h0dHA6Ly93d3cuZ3N0YXRpYy5jb20vZ2VuZXJhdGVfMjA0JwogICAgaW50ZXJ2YWw6IDI0MDAKICAgIHN0cmF0ZWd5OiByb3VuZC1yb2JpbgoKcnVsZXM6CiAgLSBET01BSU4tU1VGRklYLGdvb2dsZS5jb20sdGVzdAogIC0gRE9NQUlOLUtFWVdPUkQsZ29vZ2xlLHRlc3QKICAtIERPTUFJTixnb29nbGUuY29tLHRlc3QKICAtIEdFT0lQLENOLHRlc3QKICAtIE1BVENILHRlc3QKICAtIFNSQy1JUC1DSURSLDE5Mi4xNjguMS4yMDEvMzIsRElSRUNUCiAgLSBJUC1DSURSLDEyNy4wLjAuMC84LERJUkVDVAogIC0gRE9NQUlOLVNVRkZJWCxhZC5jb20sUkVKRUNUCg=="

    echo "$part1" | base64 -d > config.yaml
    echo "$part2" | base64 -d >> config.yaml
    echo "$part3" | base64 -d >> config.yaml
    echo "$part4" | base64 -d >> config.yaml
    echo "$part5" | base64 -d >> config.yaml


}

upload_to_r2(){

    mv config.yaml aws-config.yaml
    # 先删
    rclone deletefile r2:test/proxyfile/aws-config.yaml
    # 再上传
    rclone copy aws-config.yaml r2:test/proxyfile/
    echo "url : https://这里改成你的 r2 地址/proxyfile/aws-config.yaml"

}

status_zone_ecs_ss_libev(){

    while read -r line
    do
        echo "$ss_pass    $line    $ss_port"
    done < temp_ip.txt

    echo -e "clash file: $(pwd)/config.yaml"

}

case "$1" in
    -init)
        init
        ;;
    -start)
        start_zone_ecs_ss_libev "$2"
        gen_zone_clash_config
        status_zone_ecs_ss_libev
        upload_to_r2
        ;;
    -stop)
        stop_zone_ecs_ss_libev "$2"
        # 关2次,防止问题
        stop_zone_ecs_ss_libev "$2"
        ;;
    -status)
        gen_zone_clash_config
        status_zone_ecs_ss_libev
        ;;
    -h)
        echo -e "\033[1;34m使用 -init 初始化\033[0m"
        echo -e "\033[1;34m使用 -start 启动\033[0m"
        echo -e "\033[1;34m使用 -stop 关闭\033[0m"
        echo -e "\033[1;34m使用 -status 查询状态\033[0m"
        exit 1
        ;;
esac