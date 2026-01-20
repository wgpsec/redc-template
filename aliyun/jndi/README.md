# 注意事项

请自行替换模板中的静态资源下载链接

**请自行替换 main.tf 中 jdk-8u321-linux-x64.tar.gz 的压缩包下载地址**
- https://github.com/No-Github/Archive/releases/tag/1.0.5

对应
```
sudo wget -O jdk-8u321-linux-x64.tar.gz 'https://这里替换成你自己的静态下载地址'
```

**请自行替换 main.tf 中 JNDIExploit_feihong.zip 的压缩包下载地址**
- https://github.com/No-Github/Archive/tree/master/JNDI

对应
```
sudo wget -O JNDIExploit_feihong.zip 'https://这里替换成你自己的静态下载地址'
```

**请自行替换 main.tf 中 JNDIExploit_0x727.zip 的压缩包下载地址**
- https://github.com/No-Github/Archive/tree/master/JNDI

对应
```
sudo wget -O JNDIExploit_0x727.zip 'https://这里替换成你自己的静态下载地址'
```

**请自行替换 main.tf 中 java-chains 的压缩包下载地址**
- https://github.com/vulhub/java-chains/releases

对应
```
sudo wget -O java-chains-1.4.1.7z.7z 'https://这里替换成你自己的静态下载地址'
```

**请自行替换 main.tf 中 JNDI-Injection-Exploit-1.0-SNAPSHOT-all.jar 的压缩包下载地址**
- https://github.com/welk1n/JNDI-Injection-Exploit/releases

对应
```
sudo wget -O /root/JNDI-Injection-Exploit-1.0-SNAPSHOT-all.jar 'https://这里替换成你自己的静态下载地址'
```

**请自行替换 main.tf 中 MemShellParty 的压缩包下载地址**
- https://github.com/ReaJason/MemShellParty/releases

对应
```
sudo wget -O /root/boot-2.1.0.jar 'https://这里替换成你自己的静态下载地址'
```

**请自行替换 main.tf 中 simplehttpserver 的压缩包下载地址**
- https://github.com/projectdiscovery/simplehttpserver

对应
```
sudo wget -O simplehttpserver_0.0.5_linux_amd64.tar.gz 'https://这里替换成你自己的静态下载地址'
```

若启动场景报错，可能原因
1. 阿里云账户余额不足 (需要大于 200)
2. 与阿里云 api 网络连接超时
3. 阿里云该区域售罄或下架 instance_type 的配置机型
4. jdk未正常安装

# 场景使用

1. 使用前请按照注意事项里内容进行配置 (若空则无需配置)
2. 将该场景文件夹复制到 redc/utils/redc-templates/ 路径下
3. 使用时命令如下

开启
```
./redc -start jndi
```

查询
```
./redc -status [uuid]
```

关闭
```
./redc -stop [uuid]
```
