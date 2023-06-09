# Oscommerce V4

## 搭建Nginx

在本项目中，nginx容器和当前docker-compose分开部署，并使用network:app进行通信。如需要把nginx部署到一个docker-compose.yml中，则可以参考nginx/v1/docker-compose.yml。

Nginx的配置可以使用下方的链接

https://www.digitalocean.com/community/tools/nginx?domains.0.server.domain=www.example.com&domains.0.server.path=%2Fwww%2Fapp%2Fwww.example.com&domains.0.server.documentRoot=%2F&domains.0.server.wwwSubdomain=true&domains.0.server.redirectSubdomains=false&domains.0.https.letsEncryptEmail=example%40example.com&domains.0.php.phpServer=custom&domains.0.php.phpServerCustom=oscommerce-php%3A9000&domains.0.reverseProxy.proxyPass=http%3A%2F%2Foscommerce-php%3A9000&domains.0.routing.fallbackHtml=true&global.security.contentSecurityPolicy=default-src%20%27self%27%20http%3A%20https%3A%20ws%3A%20wss%3A%20data%3A%20blob%3A%20%27unsafe-inline%27%20%27unsafe-eval%27%3B%20frame-ancestors%20%27self%27%3B&global.tools.symlinkVhost=false

或者使用如下命令

```
echo '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' | base64 --decode | tee /www/serv/nginx/etc/nginx/nginxconfig.io-example.com.tar.gz > /dev/null
```



## 搭建环境

把本项目的docker-compose.yml文件，拷贝到/www/app/www.example.com下，并修改数据库部分的用户和密码等相关信息

运行PHP和mariaDB

```
docker compose up
```

运行MariaDB安全脚本

```
docker exec -it oscommerce-mariadb /bin/bash
/usr/bin/mariadb-secure-installation
```

除了Change root password选择N，其他都保持默认Y

## 部署应用

创建一个储存oscommerce目录

```
mkdir -p /www/app/www.example.com/oscommerce
cd /www/app/www.example.com/oscommerce
```

下载最新oscommerce，并解压

```
wget https://www.oscommerce.com/download-file
unzip download-file
```

给本项目创建一个文件夹，并修改权限，并保证上级目录www-data用户可以读取的权限

```
chown -R www-data /www/app/www.example.com/oscommerce/
chmod 755 /www
chmod 755 /www/app
chmod 755 /www/app/www.example.com
chmod 755 /www/app/www.example.com/oscommerce
```

## 安装

输入网址，https://www.example.com/，并进行安装

## 完善NGINX规则

安装完成后，默认打开不开后台以及其他demo，需要在nginx配置中改动

```
    # index.php fallback
    location ~ ^/api/ {
        try_files $uri $uri/ /index.php?$query_string;
    }
```

假设你想访问admin，则把上面的配置改成

```
    # index.php fallback
    location /admin {
        try_files $uri $uri/ /admin/index.php?$args;
    }
```
