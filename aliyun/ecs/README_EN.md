# Usage

1. Configure according to the notes before use (if empty, no configuration needed)
2. Usage commands are as follows:

Pull
```
redc pull aliyun/ecs
```

Start
```
redc run aliyun/ecs
```

Query
```
redc status [uuid]
```

Stop
```
redc stop [uuid]
```

# Notes

If starting the scenario fails, possible reasons:
1. Aliyun account balance is insufficient (needs to be greater than 200)
2. Network connection to Aliyun API timed out
3. Aliyun region sold out or instance_type configuration discontinued
