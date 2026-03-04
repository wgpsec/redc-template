# Usage

1. Configure according to the notes before use (if empty, no configuration needed)
2. Usage commands are as follows:

Pull
```
redc pull tencent/file
```

Start
```
redc run tencent/file
```

Query
```
redc status [uuid]
```

Stop
```
redc stop [uuid]
```

# Static Resources

**If not using redc, please replace the Tencent Cloud aksk in terraform.tfvars yourself**

```
tencentcloud_secret_id  = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
tencentcloud_secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

You can replace the static resource download links in the template yourself, currently using accelerated links from https://ghproxy.link/

**You can replace the simplehttpserver archive download link in main.tf yourself**
- https://github.com/projectdiscovery/simplehttpserver

**You can replace the GitHub acceleration address in terraform.tfvars yourself**
- https://ghfast.top/github.com

# Notes

If starting the scenario fails, possible reasons:
1. Tencent Cloud account balance is insufficient
2. Network connection to Tencent Cloud API timed out
3. Tencent Cloud region sold out or instance_type configuration discontinued
