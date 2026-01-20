# 注意事项

请自行替换模板中的静态资源下载链接

**替换 terraform.tfvars 中的 腾讯云 aksk**

```
tencentcloud_secret_id  = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
tencentcloud_secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

**请自行替换 main.tf 中 linux_amd64_server.tar.gz 的压缩包下载地址**
- https://github.com/ehang-io/nps/releases

对应
```
sudo wget -O linux_amd64_server.tar.gz 'https://这里替换成你自己的静态下载地址'
```

若启动场景报错，可能原因
1. 腾讯云账户余额不足
2. 与腾讯云 api 网络连接超时
3. 腾讯云该区域售罄或下架 instance_type 的配置机型
4. jdk未正常安装

# 场景使用

1. 使用前请按照注意事项里内容进行配置 (若空则无需配置)
2. 将该场景文件夹复制到 redc/utils/redc-templates/ 路径下
3. 使用时命令如下

开启
```
./redc -start nps

# 如果要在启动时加载自定义nps.conf配置,需要base64后传入
./redc -start nps -base64command "YXBwbmFtZSA9IG5wcwojQm9vdCBtb2RlKGRldnxwcm8pCnJ1bm1vZGUgPSBkZXYKCiNIVFRQKFMpIHByb3h5IHBvcnQsIG5vIHN0YXJ0dXAgaWYgZW1wdHkKaHR0cF9wcm94eV9pcD0wLjAuMC4wCmh0dHBfcHJveHlfcG9ydD04MApodHRwc19wcm94eV9wb3J0PTQ0MwpodHRwc19qdXN0X3Byb3h5PXRydWUKI2RlZmF1bHQgaHR0cHMgY2VydGlmaWNhdGUgc2V0dGluZwpodHRwc19kZWZhdWx0X2NlcnRfZmlsZT1jb25mL3NlcnZlci5wZW0KaHR0cHNfZGVmYXVsdF9rZXlfZmlsZT1jb25mL3NlcnZlci5rZXkKCiMjYnJpZGdlCmJyaWRnZV90eXBlPXRjcApicmlkZ2VfcG9ydD04MDI0CmJyaWRnZV9pcD0wLjAuMC4wCgojIFB1YmxpYyBwYXNzd29yZCwgd2hpY2ggY2xpZW50cyBjYW4gdXNlIHRvIGNvbm5lY3QgdG8gdGhlIHNlcnZlcgojIEFmdGVyIHRoZSBjb25uZWN0aW9uLCB0aGUgc2VydmVyIHdpbGwgYmUgYWJsZSB0byBvcGVuIHJlbGV2YW50IHBvcnRzIGFuZCBwYXJzZSByZWxhdGVkIGRvbWFpbiBuYW1lcyBhY2NvcmRpbmcgdG8gaXRzIG93biBjb25maWd1cmF0aW9uIGZpbGUuCnB1YmxpY192a2V5PTEyMwoKI1RyYWZmaWMgZGF0YSBwZXJzaXN0ZW5jZSBpbnRlcnZhbChtaW51dGUpCiNJZ25vcmFuY2UgbWVhbnMgbm8gcGVyc2lzdGVuY2UKI2Zsb3dfc3RvcmVfaW50ZXJ2YWw9MQoKIyBsb2cgbGV2ZWwgTGV2ZWxFbWVyZ2VuY3ktPjAgIExldmVsQWxlcnQtPjEgTGV2ZWxDcml0aWNhbC0+MiBMZXZlbEVycm9yLT4zIExldmVsV2FybmluZy0+NCBMZXZlbE5vdGljZS0+NSBMZXZlbEluZm9ybWF0aW9uYWwtPjYgTGV2ZWxEZWJ1Zy0+Nwpsb2dfbGV2ZWw9NwojbG9nX3BhdGg9bnBzLmxvZwoKI1doZXRoZXIgdG8gcmVzdHJpY3QgSVAgYWNjZXNzLCB0cnVlIG9yIGZhbHNlIG9yIGlnbm9yZQojaXBfbGltaXQ9dHJ1ZQoKI3AycAojcDJwX2lwPTEyNy4wLjAuMQojcDJwX3BvcnQ9NjAwMAoKI3dlYgp3ZWJfaG9zdD1hLm8uY29tCndlYl91c2VybmFtZT1yZWRvbmUKd2ViX3Bhc3N3b3JkPTEhMkEzZDR2NXM2ZQp3ZWJfcG9ydCA9IDgwODAKd2ViX2lwPTAuMC4wLjAKd2ViX2Jhc2VfdXJsPQp3ZWJfb3Blbl9zc2w9ZmFsc2UKd2ViX2NlcnRfZmlsZT1jb25mL3NlcnZlci5wZW0Kd2ViX2tleV9maWxlPWNvbmYvc2VydmVyLmtleQojIGlmIHdlYiB1bmRlciBwcm94eSB1c2Ugc3ViIHBhdGguIGxpa2UgaHR0cDovL2hvc3QvbnBzIG5lZWQgdGhpcy4KI3dlYl9iYXNlX3VybD0vbnBzCgojV2ViIEFQSSB1bmF1dGhlbnRpY2F0ZWQgSVAgYWRkcmVzcyh0aGUgbGVuIG9mIGF1dGhfY3J5cHRfa2V5IG11c3QgYmUgMTYpCiNSZW1vdmUgY29tbWVudHMgaWYgbmVlZGVkCmF1dGhfa2V5PXJlZHJlZHJlZAphdXRoX2NyeXB0X2tleSA9MTIzNDU2NzgxMjM0NTY3OQoKI2FsbG93X3BvcnRzPTkwMDEtOTAwOSwxMDAwMSwxMTAwMC0xMjAwMAoKI1dlYiBtYW5hZ2VtZW50IG11bHRpLXVzZXIgbG9naW4KYWxsb3dfdXNlcl9sb2dpbj1mYWxzZQphbGxvd191c2VyX3JlZ2lzdGVyPWZhbHNlCmFsbG93X3VzZXJfY2hhbmdlX3VzZXJuYW1lPWZhbHNlCgoKI2V4dGVuc2lvbgphbGxvd19mbG93X2xpbWl0PWZhbHNlCmFsbG93X3JhdGVfbGltaXQ9ZmFsc2UKYWxsb3dfdHVubmVsX251bV9saW1pdD1mYWxzZQphbGxvd19sb2NhbF9wcm94eT1mYWxzZQphbGxvd19jb25uZWN0aW9uX251bV9saW1pdD1mYWxzZQphbGxvd19tdWx0aV9pcD1mYWxzZQpzeXN0ZW1faW5mb19kaXNwbGF5PWZhbHNlCgojY2FjaGUKaHR0cF9jYWNoZT1mYWxzZQpodHRwX2NhY2hlX2xlbmd0aD0xMDAKCiNnZXQgb3JpZ2luIGlwCmh0dHBfYWRkX29yaWdpbl9oZWFkZXI9ZmFsc2UKCiNwcHJvZiBkZWJ1ZyBvcHRpb25zCiNwcHJvZl9pcD0wLjAuMC4wCiNwcHJvZl9wb3J0PTk5OTkKCiNjbGllbnQgZGlzY29ubmVjdCB0aW1lb3V0CmRpc2Nvbm5lY3RfdGltZW91dD02MA=="
```

默认的配置
```
appname = nps
#Boot mode(dev|pro)
runmode = dev

#HTTP(S) proxy port, no startup if empty
http_proxy_ip=0.0.0.0
http_proxy_port=80
https_proxy_port=443
https_just_proxy=true
#default https certificate setting
https_default_cert_file=conf/server.pem
https_default_key_file=conf/server.key

##bridge
bridge_type=tcp
bridge_port=8001
bridge_ip=0.0.0.0

# Public password, which clients can use to connect to the server
# After the connection, the server will be able to open relevant ports and parse related domain names according to its own configuration file.
public_vkey=123

#Traffic data persistence interval(minute)
#Ignorance means no persistence
#flow_store_interval=1

# log level LevelEmergency->0  LevelAlert->1 LevelCritical->2 LevelError->3 LevelWarning->4 LevelNotice->5 LevelInformational->6 LevelDebug->7
log_level=7
#log_path=nps.log

#Whether to restrict IP access, true or false or ignore
#ip_limit=true

#p2p
#p2p_ip=127.0.0.1
#p2p_port=6000

#web
web_host=a.o.com
web_username=redone
web_password=1!2A3d4v5s6e
web_port = 8080
web_ip=0.0.0.0
web_base_url=
web_open_ssl=false
web_cert_file=conf/server.pem
web_key_file=conf/server.key
# if web under proxy use sub path. like http://host/nps need this.
#web_base_url=/nps

#Web API unauthenticated IP address(the len of auth_crypt_key must be 16)
#Remove comments if needed
auth_key=redredred
auth_crypt_key =1234567812345679

#allow_ports=9001-9009,10001,11000-12000

#Web management multi-user login
allow_user_login=false
allow_user_register=false
allow_user_change_username=false


#extension
allow_flow_limit=false
allow_rate_limit=false
allow_tunnel_num_limit=false
allow_local_proxy=false
allow_connection_num_limit=false
allow_multi_ip=false
system_info_display=false

#cache
http_cache=false
http_cache_length=100

#get origin ip
http_add_origin_header=false

#pprof debug options
#pprof_ip=0.0.0.0
#pprof_port=9999

#client disconnect timeout
disconnect_timeout=60
```

查询
```
./redc -status [uuid]
```

关闭
```
./redc -stop [uuid]
```
