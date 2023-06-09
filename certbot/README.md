# Certbot

## 使用Certbot镜像获取证书

创建certbot文件夹

```
mkdir -p /www/serv/certbot
```

以www.example.com网站为例，在/www/serv/certbot目录下，创建一个docker-compose-www.example.com.yml，参考本目录的www.example.com.yml文件

> 如果还有更多网站，则再创建一个docker-compose-xxxxx.yml，并修改文件内的command为即可，其他内容不变

**更改.well-known/acme-challenge权限**

更改/www/serv/nginx/var/www/_letsencrypt/目录权限，否则获取证书时会报错，且访问http://www.example.com/.well-known/acme-challenge/会提示403错误。

```chmod
chmod 755 /www/serv/nginx/var/www/_letsencrypt/
```

**设置定时脚本**

在/www/serv/certbot下创建一个脚本 `auto-renewal.sh`，参考本目录的auto-renewal.sh文件

设置可执行，`chmod +x auto-renewal.sh`

运行脚本 `./auto-renewal.sh`

**设置定时任务**

设置定时任务，crontab -e

```
0 0 2 1 * ? sh /www/serv/certbot/auto-renewal.sh
```

 查看是否正常

```
/etc/init.d/cron start
crontab -l
```
