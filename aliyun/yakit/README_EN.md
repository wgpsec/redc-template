# Usage

1. Configure according to the notes before use (if empty, no configuration needed)
2. Usage commands are as follows:

Pull
```
redc pull aliyun/yakit
```

Start
```
redc run aliyun/yakit
```

Query
```
redc status [uuid]
```

Stop
```
redc stop [uuid]
```

3. After deployment, you can connect to the Yakit server in the following ways:
   - Connect using the Yakit client to the server IP on port 8087 (default)
   - SSH login to the server: `ssh root@<serverIP>`, password is in the `redc status` output

# Static Resources

In this scenario, the Yakit server (yak) is downloaded directly from Aliyun OSS bucket without GitHub proxy.

Download link: https://yaklang.oss-cn-beijing.aliyunc.com/yak/latest/yak_linux_amd64

To change the version or download link, modify the download link in the user_data section of main.tf.

# Notes

**Port Configuration**

Default Yakit server listens on port 8087. You can customize the port by modifying the `yakit_port` parameter in `terraform.tfvars`:

```
yakit_port = 8087
```

Or specify via `-e` parameter at runtime:
```
redc run aliyun/yakit -e yakit_port=9999
```

**Instance Type**

This scenario uses ecs.c7a.large (2 cores 4GB). If this type is unavailable or sold out in some regions, you can modify the `instance_type` in main.tf to other types, for example:
- ecs.n1.small (1 core 2GB)
- ecs.c7.large (2 cores 4GB)
- ecs.g7.large (2 cores 8GB)

**Region Configuration**

Default deployment is in Beijing (cn-beijing). You can modify the `region` parameter in versions.tf to change the deployment region.

If starting the scenario fails, possible reasons:
1. Aliyun account balance is insufficient (needs to be greater than 200)
2. Network connection to Aliyun API timed out
3. Aliyun region sold out or instance_type configuration discontinued
4. Yakit service failed to start. You can check logs by logging into the server: `systemctl status yakit`
5. OSS download link expired or network issues preventing yak binary download
