---
layout:     post
title:      "CentOS LAMP/LEMP 等各种服务环境搭建"
subtitle:   "nginx,apache,mysql,php,java,tomcat,...."
date:       2017-03-31
author:     "vincent"
header-img: "img/post-bg-10-centos-lamp.jpg"
catalog: true
tags:
    - web服务器
---


> 由于之前捣鼓学习一些东西所作的笔记等都存放在印象笔记中，比较分散和杂乱。加上又准备更新自己的博客，
于是将折腾阿里云服务器整理出来，这篇会持续更新。(*^__^*) 

## L - Linux > 一台云服务器

首先你得有一台云服务器。常用的云服务提供商有，`阿里云`，`腾讯云`，`亚马逊 AWS`，`微软 Azure`等。
但是在国内的话，个人还是比较推荐阿里云。最低配一个月60块钱的样子。

购买后阿里云会给你分配一个云服务器的公网IP地址。通过 SSH 连接云服务器：

```
ssh root@xxx.xxx.xxx.xxx

输入密码
```

## yum

> Yum（全称为 Yellow dog Updater, Modified）是一个在Fedora和RedHat以及CentOS中的Shell前端软件包管理器。基于RPM包管理，能够从指定的服务器自动下载RPM包并且安装，可以自动处理依赖性关系，并且一次安装所有依赖的软件包，无须繁琐地一次次下载、安装。
	
通过 yum 命令我们可以很方便的安装管理例如 mysql，php等常用的软件包服务。

yum 命令格式为：

```
yum [options] [command] [package ...]
```

#### 更新源

```
yum update

yum upgrade
```

## A - Apache -> httpd

Apache 在Linux系统中，叫 **httpd**。O__O "…

#### 安装 Apache

```
yum install httpd
```

**>** 启动Apache

```
systemctl start httpd.service 
```

这时在浏览器中输入IP地址，你可以看到Apache的Test页面。

**>** 关闭Apache

```
systemctl stop httpd.service
```

**>** 设置Apache开启自动启动

```
systemctl enable httpd.service 
```

#### 使用

Apache 在CentOS中默认的根目录在 `/var/www/html`

Apache 相关的配置文件目录在 `/etc/httpd/conf/httpd.conf`

其他相关的配置文件目录在 `/etc/httpd/conf.d/`

## J - Java 

查看可用的 JDK软件包列表:

```
yum search java | grep -i --color JDK
```

安装 java-jdk 

```
yum install java-1.8.0-openjdk  java-1.8.0-openjdk-devel  #安装openjdk
```

查看当前 java 版本

```
java -version     #查看java版本
```

java 存放的地址  `/usr/lib/jvm`

#### 配置 Java 环境变量

将 jdk 拷贝到 /usr/local/java 目录下。没有的话 `mkdir`创建，统一放到 /usr/local 目录下便于管理。

```
cd /usr/lib/jvm

cp -R java-1.8.0-openjdk /usr/local/java/jdk1.8
```

###### 配置环境变量

```
vi /etc/profile
```

将下面内容添加到文件末尾，for循环后面。这里直接引用 /usr/lib/jvm 目录下的 JDK也是可以的。

```
export JAVA_HOME=/usr/local/java/jdk1.8
export PATH=$JAVA_HOME/bin:$PATH:
export JAVA_BIN=$JAVA_HOME/bin
export CLASSPATH=.:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar
export JAVA_HOME JAVA_BIN PATH CLASSPAT
```

让配置立即生效

```
source /etc/profile
```

检查环境变量

```
# echo $JAVA_HOME

-> /usr/local/java/jdk1.8
```

## T - Tomcat 

Tomcat 官网 : [http://tomcat.apache.org/](http://tomcat.apache.org/)

选择一个版本的 tar.gz 文件进行下载

```
# wget http://ftp.cuhk.edu.hk/pub/packages/apache.org/tomcat/tomcat-6/v6.0.51/bin/apache-tomcat-6.0.51.tar.gz

# tar -zxvf apache-tomcat-6.0.51.tar.gz   # 解压

拷贝 tomcat 到 /usr/local 目录下

# cp -R apache-tomcat-6.0.51 /usr/local/tomcat7
```

#### 使用

启动Tomcat

```
cd /usr/local/tomcat7/bin

sh startup.sh
```

停止Tomcat

```
sh shutdown.sh
```

## M - MySQL -> MariaDB

MySQL本身是开源免费的，但是在Mysql被Oracle收购后，有将MySQL闭源的风险。MariaDB是MySQL源代码的一个分支，是由MySQL的创始人麦克尔·维德纽斯主导开发，使用这些分支避免这个潜在的风险。

详细的一些区别参考这篇：[浅谈MySQL和mariadb区别](http://bijian1013.iteye.com/blog/2315665)

*>* centOS 7 以后，软件源中默认的是MariaDB 而不是MySQL

**>** 安装 MariaDB

```
yum install mariadb-server -y
```

**>** 启动 MariaDB

```
systemctl start mariadb.service
```

**>** 停止 MariaDB

```
systemctl stop mariadb.service
```

**>** 设置开启自动启动

```
systemctl enable mariadb.service
```

进入MySQL，第一次进入不用密码需要自己修改

```
[root@VM_140_194_centos ~]# mysql
```
![](/img/centos-lnmp/mysql-login.png)

**>** 修改MySQL密码

```
mysql_secure_installation
```

根据提示进行设置。

用户权限管理设置等：[MySQL用户权限管理](http://blog.csdn.net/xyang81/article/details/51822252)

## P - PHP

我自己使用到PHP的地方一般也只是用它来使用 **PHPMyAdmin**，而web服务也是用 Java或者Python开发的，所以PHP用得比较少。

#### 安装

```
yum install php
```

**>** 需要重启一下Apache服务

```
service httpd restart
```

测试一下是否安装好

```
# vi /var/www/html/info.php

输入 i 进行插入

# <?php phpinfo(); ?>

ESC -> 英文冒号 -> wq 保存退出
```

然后再浏览器地址中输入 `ip地址/info.php`，这时应该能看到到当前的 php信息。

#### 关联 PHP 和 MySQL

```
yum install php-mysql php-gd php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc
```

安装完后重启 Apache

```
systemctl restart httpd.service
或者
service httpd restart
```

然后在 info.php 中就能看到mysql的模块。

#### 安装 phpMyadmin

```
yum install phpMyAdmin php-mcrypt
```

安装完后会在 `/usr/share` 目录下有个 **phpMydmin**目录，将该目录拷贝的 html 目录下。

```
# cd /usr/share
# cp -a phpMyAdmin/ /var/www/html/phpmyadmin
```

###### 一些错误

The mbstring extension is missing. Please check your PHP configuration.
	
```
# vi /etc/php.ini
	
在 [PHP] 下面插入
	
# extension=php_mbstring.dll
   
* 重启 httpd.service
```

You don't have permission to access /phpmyadmin/ on this server.

```
vi /etc/httpd/conf.d/phpMyAdmin.conf
```
![](/img/centos-lnmp/phpmyadmin-permission.png)

## N - Nginx 

#### 有了Apache为什么要使用 Nginx

> [Apache, Tomcat, Nginx的区别](http://willis.blog.51cto.com/11907152/1852083)

Apache 和 Nginx 都叫做 [*HTTP Server*]，Tomcat这一类的则是 [*Application Server*]。

Nginx 相对于Apache而言，具有

#### 安装

```
yum install nginx
```

**>** 启动 Nginx 。注意，Apache和Nginx默认都是监听的80端口，所以注意端口占用，要么修改默认的端口。

```
# nginx
```
**>** 停止nginx

```
nginx -s stop
```

**>** 重启nginx

```
# nginx -s reload
```

nginx 相关配置文件路径 ：`/etc/nginx/nginx.conf`

## R - Redis

Redis是一个开源的使用ANSI C语言编写、支持网络、可基于内存亦可持久化的日志型、Key-Value数据库，并提供多种语言的API。

**>** 安装 

```
yum install -y redis
```

**>** 启动

```
systemctl start redis
```

**>** 开机启动

```
systemctl enable redis
```

**>** 停止

```
systemctl stop redis
```

## F - FTP

**vsftpd** 是Linux 下比较著名的FTP服务器。

**>**安装

```
yum -y install vsftpd
```

**>**相关操作

```
# systemctl start vsftpd     # 启动 vsftpd
# systemctl enable vsftpd		# 设置开机启动
# systemctl stop vsftpd		# 停止 vsftpd
```

#### 修改配置文件

打开 **/etc/vsftpd/vsftpd.conf**，修改配置：

```
anonymous_enable=NO 	#设定不允许匿名访问
local_enable=YES 			#设定本地用户可以访问。注：如使用虚拟宿主用户，在该项目设定为NO的情况下所有虚拟用户将无法访问
ascii_upload_enable=YES
ascii_download_enable=YES #设定支持ASCII模式的上传和下载功能
chroot_list_enable=YES 	#使用户不能离开主目录
pam_service_name=vsftpd   #PAM认证文件名。PAM将根据/etc/pam.d/vsftpd进行认证
```

以下这些是关于vsftpd虚拟用户支持的重要配置项，默认vsftpd.conf中不包含这些设定项目，需要自己手动添加

```
guest_enable=YES			#设定启用虚拟用户功能
guest_username=ftp		#指定虚拟用户的宿主用户，CentOS中已经有内置的ftp用户了
user_config_dir=/etc/vsftpd/vuser_conf #设定虚拟用户个人vsftp的CentOS FTP服务文件存放路径。存放虚拟用户个性的CentOS FTP服务文件(配置文件名=虚拟用户名
```

#### 添加用户

```
useradd vicnent 	# 添加一个用户
passwd vincent		# 给用户设置密码
```

在 `/home` 路径下，就会多出一个 **vincent** 的文件夹。

然后就可以在其他电脑上通过FileZilla这类的FTP软件进行上传下载文件了。但是要注意文件的权限。




