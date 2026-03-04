# Usage

1. **Must** configure according to the notes before use (if empty, no configuration needed)
2. Usage commands are as follows:

Pull
```
redc pull aws/docker
```

Start
```
redc run aws/docker
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

**Region Configuration**

Enable AWS ap-east-1 (Hong Kong) region

![](../../img/redc-2.png)

![](../../img/redc-3.png)

Installation progress can be viewed in tmux

If starting the scenario fails, possible reasons:
1. Network connection to AWS API timed out
2. AWS region sold out or instance_type configuration discontinued
3. AMI architecture does not match instance_type
