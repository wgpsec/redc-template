# Usage

1. Configure according to the notes before use (if empty, no configuration needed)
2. Usage commands are as follows:

Pull
```
redc pull aliyun/file
```

Start
```
redc run aliyun/file
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

You can replace the static resource download links in the template yourself, currently using accelerated links from https://ghproxy.link/

**You can replace the simplehttpserver archive download link in main.tf yourself**
- https://github.com/projectdiscovery/simplehttpserver

**You can replace the GitHub acceleration address in terraform.tfvars yourself**
- https://ghfast.top/github.com

# Notes

If starting the scenario fails, possible reasons:
1. Aliyun account balance is insufficient (needs to be greater than 200)
2. Network connection to Aliyun API timed out
3. Aliyun region sold out or instance_type configuration discontinued
