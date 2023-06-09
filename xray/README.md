# Xray

## 配置xray

**创建xray目录**

```
mkdir -p /www/serv/xray/etc/xray
```

在/www/serv/xray下面创建一个docker-compose文件，文件内容参照本项目的docker-compose.yml文件。

**配置文件**

配置教程：具体配置方法可以参考[【第 7 章】Xray 服务器篇 | Project X (xtls.github.io)](https://xtls.github.io/Xray-docs-next/document/level-0/ch07-xray-server.html#_7-4-%E9%85%8D%E7%BD%AE-xray)

创建Xray的配置文件，配置文件可以

1. 参考官方的example，VLESS-WSS-Nginx部分
   [Xray-examples/VLESS-WSS-Nginx at main · XTLS/Xray-examples (github.com)](https://github.com/XTLS/Xray-examples/tree/main/VLESS-WSS-Nginx)
2. 参考本项目的server.json

```
vim /www/serv/xray/etc/xray/config.json
```

把官方config_server.json修改成你需要的配置放入 `/www/serv/xray/etc/xray/config.json`，

**启动xray容器**

```
docker compose up
```

## 搭建Nginx

在本项目中，nginx容器和当前docker-compose分开部署，并使用network:app进行通信。如需要把nginx部署到一个docker-compose.yml中，则可以参考nginx/v1/docker-compose.yml。

Nginx的配置可以使用下方的链接

## 配置Nginx

首先创建一个xray的nginx配置文件

`vim /www/serv/nginx/etc/nginx/sites-enabled/xray.conf`

配置文件可以：

1. 参考官方nginx配置的写法 [Xray-examples/VLESS-WSS-Nginx at main · XTLS/Xray-examples · GitHub](https://github.com/XTLS/Xray-examples/tree/main/VLESS-WSS-Nginx)
2. 参考本目录下的nginx.conf文件

**获取证书**

注释SSL部分

```
sed -i -r 's/(listen .*443)/\1; #/g; s/(ssl_(certificate|certificate_key|trusted_certificate) )/#;#\1/g; s/(server \{)/\1\n    ssl off;/g' /www/serv/nginx/etc/nginx/sites-enabled/xray.conf
```

创建certbot的docker-compose文件

```
vim /www/serv/certbot/docker-compose-xray.yml
cd /www/serv/certbot
docker compose -f docker-compose-xray.yml up
```

**重载配置**

```
docker exec -it nginx bash -c "nginx -t && nginx -s reload"
```

## 站点伪装

创建HTML目录

```
mkdir -p /www/app/xray
cd /www/app/xray
git clone https://github.com/star574/camouflage_html.git .
chown -R www-data xray/
```

## 开启BBR

开启BBR过程参考：[【第 7 章】Xray 服务器篇 | Project X (xtls.github.io)](https://xtls.github.io/document/level-0/ch07-xray-server.html#_7-7-%E6%9C%8D%E5%8A%A1%E5%99%A8%E4%BC%98%E5%8C%96%E4%B9%8B%E4%B8%80-%E5%BC%80%E5%90%AF-bbr)

**开启BBR**

```
vim /etc/apt/sources.list
```

以debian10为例，新增

```
deb http://deb.debian.org/debian buster-backports main
```

保存退出后更新源

```bash
apt update && apt -t buster-backports install linux-image-amd64
```

修改kernel

```bash
vim /etc/sysctl.conf
```

新增以下两行

```
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
```

**检测BBR**

分别输入以下两行命令，检测是否有返回 `tcp_bbr` 及 `sch_fq`，如果没有任何返回，则说明开启失败

```
lsmod | grep bbr
lsmod | grep fq
```
