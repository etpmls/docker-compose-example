## 前提

1. 确保你已经安装了docker

## 创建容器

先创建一个nginxconfig.io要操作的文件夹

```
mkdir -p /www/serv/nginx/etc/nginx
```

把nginxconfig.io的配置导入到服务器的/www/serv/nginx目录下

```
cd /www/serv/nginx/etc/nginx
```

如果以前存在文件，则备份历史文件

```
tar -czvf nginx_$(date +'%F_%H-%M-%S').tar.gz nginx.conf sites-available/ sites-enabled/ nginxconfig.io/
```

解压文件

```
tar -xzvf nginxconfig.io-example.com.tar.gz | xargs chmod 0644
```

如果网址不需要https，则可以直接启动Nginx容器，如果需要，跳过本步骤，继续往下配置。

```
cd /www/serv/nginx/
docker compose up

```

## 创建SSL

在宿主机上生成dhparam.pem

```
openssl dhparam -out /www/serv/nginx/etc/nginx/dhparam.pem 2048
```

创建ACME-challenge目录

```
mkdir -p /www/serv/nginx/var/www/_letsencrypt
chown www-data /www/serv/nginx/var/www/_letsencrypt
```

注释SSL部分

```
sed -i -r 's/(listen .*443)/\1; #/g; s/(ssl_(certificate|certificate_key|trusted_certificate) )/#;#\1/g; s/(server \{)/\1\n    ssl off;/g' /www/serv/nginx/etc/nginx/sites-enabled/example.com.conf
```

移除之前存在的容器并重新挂载(防止挂载报错，比如之前不存在dhparam.pem，但是你已经运行了容器，容器会视dhparam.pem为文件夹，你再次启动，新创建的本地的dhparam.pem文件却挂载之前的dhparam.pem文件夹，nginx容器会报错)

```
docker compose down
docker compose up
```

**使用certbot镜像获取证书**

参考本项目的certbot/README.md

取消注释

```
sed -i -r -z 's/#?; ?#//g; s/(server \{)\n    ssl off;/\1/g' /www/serv/nginx/etc/nginx/sites-enabled/example.com.conf
```

重启nginx docker容器

```
docker exec -it nginx bash -c "nginx -t && nginx -s reload"
```
