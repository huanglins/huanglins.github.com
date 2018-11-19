---
layout:     post
title:      "Mysql 主从备份和读写分离实践"
subtitle:   ""
date:       2018-10-30
author:     "vincent"
header-img: "img/post-bg-18-mysql-slave.jpg"
header-style: text
catalog: true
tags:
    - MySQL
---

## 1. 主从备份

#### 1.1 原理
mysql支持单向、异步复制，复制过程中一个服务器充当主服务器，而一个或多个其它服务器充当从服务器。mysql复制基于主服务器在二进制日志中跟踪所有对数据库的更改(更新、删除等等)。因此，要进行复制，必须在主服务器上启用二进制日志。每个从服务器从主服务器接收主服务器已经记录到其二进制日志的保存的更新。当一个从服务器连接主服务器时，它通知主服务器从服务器在日志中读取的最后一次成功更新的位置。从服务器接收从那时起发生的任何更新，并在本机上执行相同的更新。然后封锁并等待主服务器通知新的更新。从服务器执行备份不会干扰主服务器，在备份过程中主服务器可以继续处理更新。

#### 1.2 支持复制类型
1. **基于语句的复制**：在主服务器上执行的SQL语句，在从服务器上执行同样的语句。MySQL默认采用基于语句的复制，效率比较高。  一旦发现没法精确复制时，会自动选着基于行的复制。 
    ```
    binlog_format=Statement
    ```
2. **基于行的复制**：把改变的内容复制过去，而不是把命令在从服务器上执行一遍. 从mysql5.0开始支持
    ```
    binlog_format=Row
    ```
3. **混合类型的复制**：默认采用基于语句的复制，一旦发现基于语句的无法精确的复制时，就会采用基于行的复制。
    ```
    binlog_format=mixed
    ```

#### 1.3 复制解决的问题
1. **数据分布 (Data distribution )**
2. **负载平衡(load balancing)**
3. **备份(Backups)**
4. **高可用性和容错行 High availability and failover**

#### 1.4 复制如何工作
1. master 将改变记录到二进制日志(binary log)中（这些记录叫做二进制日志事件，binary log events）
2. slave 将 master 的 binary log events 拷贝到它的中继日志(relay log)
3. slave 重做中继日志中的事件，将改变反映它自己的数据。
![](/img/p-mysql-slave/15408656565076.jpg)

master 接收到了SQL的时候，会存入到一个 binlog 的文件并入库，binlog 数据存储完毕后会开启一个 dump thread 线程，
这个线程会将 binlog 的数据同步到slave的io thread，io thread将数据存储到delay binlog（中继日志），启动一个sql thread
将数据写入slave的binlog和data中。binlog有个position的字段，和RandomAccessFile中的指针的概念是一样的，会记录上次的位置，这样就可以将binlog的数据从新的position开始同步，不会造成重复。

## 2. 主从备份实践

#### 2.1 配置主服务器
```
vi /etc/my.conf
```
在 `[mysqld]` 下面配置以下参数
```
# 1. 主从备份相关配置
server-id = 1	            # 服务器 id 号，不要和其他服务器重复
log-bin=mysql-bin		    # 开启二进制日志
log_bin_index = mysql-bin.index	    # 索引二进制日志的文件名
sync_binlog = 1			    # 设为1就是把MySql每次发生的修改和事件的日志即时同步到硬盘上
binlog_format = Row		    # 复制模式 Statement, Row, mixed
skip_slave_start = 1	    # 防止从服务器在崩溃后自动开启，以给你足够的时间修复。
max_binlog_size = 200M 	    # 指定二进制日志的大小

# 1.1 需要同步的二进制数据库名
binlog-do-db = test
# 1.2 不同步的二进制数据库名,如果不设置可以将其注释掉
binlog-ignore-db = information_schema
binlog-ignore-db = mysql

```

重启 mysql
```
service mysqld restart
```
查看修改结果
```
show variables like 'server%'; 
show master status; 
```
![Screen Shot 2018-10-30 at 11.06.31 A](/img/p-mysql-slave/Screen%20Shot%202018-10-30%20at%2011.06.31%20AM.png)

#### 2.1.1 重启出现报错
1. **Can't connect to local MySQL server through socket '/var/lib/mysql/mysql.sock' (2)**

    ```
    rm -fr /var/lib/mysql/*
    ```
2. **Access denied for user 'root'@'localhost' (using password: YES)**

    ```
    > service mysqld stop
    > mysqld_safe --user=mysql --skip-grant-tables --skip-networking &
    > msyql -u root mysql
    
    然后重新设置密码
    ```
    
#### 2.2 配置从服务器
```
vi /etc/my.conf
```
在 `[mysqld]` 下面配置以下参数
```
# 1. 主从备份相关配置 - 从服务器
# 不在这里配置主服务器信息，而是通过命令来配置
server-id = 2			# 服务器 id 号，不要和其他服务器重复
read_only = 1			# 让从服务器只读，可以防止有人误从服务器插入数据，导致主从数据不一致。 
log-bin=mysql-bin		# 开启二进制日志
log_bin_index = mysql-bin.index	# 索引二进制日志的文件名
log_slave_updates = 1
relay_log = mysql-relay-bin 	# 中继日志 
relay_log_index = mysql-relay-bin.index
skip_slave_start = 1		# 防止从服务器在崩溃后自动开启，以给你足够的时间修复。 
max_binlog_size = 200M 			# 指定二进制日志的大小

# 以下配置是为了方便以后，从库切换为主库
# 1.1 需要同步的二进制数据库名
binlog-do-db = test
# 1.2 不同步的二进制数据库名,如果不设置可以将其注释掉
binlog-ignore-db = information_schema
binlog-ignore-db = mysql
```

#### 2.2 关联从库的主数据库，并开始备份

在主数据库中创建专门用于复制的账号：
```
GRANT REPLICATION SLAVE ON *.* to 'repl'@'144.%.%.%' identified by '123456';
FLUSH PRIVILEGES;
```
这是测试为 ip 地址 144 开头的服务器可以访问，不建议用 `%` 测试全部。

在从数据库中执行命令
```
CHANGE MASTER TO
             MASTER_HOST='master_host_name',
             MASTER_USER='replication_user_name',
             MASTER_PASSWORD='replication_password',
             MASTER_LOG_FILE='recorded_log_file_name',
             MASTER_LOG_POS=recorded_log_position;
             
-------------------------------------------------------
master_host_name        主数据库 ip 地址
replication_user_name   主数据操作账号      repl
replication_password    主数据库操作密码     自己设定
recorded_log_file_name  主数据 show master status; 查看到的 File
recorded_log_position   主数据 show master status; 查看到的 Position
```
开始操作
```
START SLAVE; 

STOP SLAVE;     # 停止
```
查看使用状态
```
SHOW SLAVE STATUS;
```

![Screen Shot 2018-10-30 at 2.20.56 P](/img/p-mysql-slave/Screen%20Shot%202018-10-30%20at%202.20.56%20PM.png)


可以看出当前从服务器已经在等待主服务器的 event 了，此时我们在主数据库的 `test` 库操作数据，看下是否已经自动同步过来了。

## 3. 读写分离
读写分离就是在主服务器上修改，数据会同步到从服务器，从服务器只能提供读取数据，不能写入，实现备份的同时也实现了数据库性能的优化，以及提升了服务器安全。 
![](/img/p-mysql-slave/15408811811696.png)

#### 3.1 读写分离实现方式

- **程序修改mysql操作类**
    优点：直接和数据库通信，简单快捷的读写分离和随机的方式实现的负载均衡，权限独立分配
    缺点：自己维护更新，增减服务器在代码处理
    
- **amoeba**

    优点：直接实现读写分离和负载均衡，不用修改代码，有很灵活的数据解决方案
    缺点：自己分配账户，和后端数据库权限管理独立，权限处理不够灵活
    
- **mysql-proxy** 

    ![](/img/p-mysql-slave/15408909948035.jpg)
    优点：直接实现读写分离和负载均衡，不用修改代码，master和slave用一样的帐号
    缺点：字符集问题，lua语言编程，还只是alpha版本，时间消耗有点高
    
#### 3.2 Mysql-Proxy

安装响应依赖库
```
yum -y install gcc* gcc-c++* autoconf* automake* zlib* libxml* ncurses-devel* libmcrypt* libtool* flex* pkgconfig* libevent* glib*
```

#### 3.3 程序修改

因为每个后台实现方式都不一样，这里后续再进行更新

## 参考链接
[mysql主从备份及原理分析](https://blog.csdn.net/qmhball/article/details/8233769)
[高性能Mysql主从架构的复制原理及配置详解](https://blog.csdn.net/hguisu/article/details/7325124)
[MySQL主从复制（Master-Slave）与读写分离（MySQL-Proxy）实践](https://blog.csdn.net/Gavid0124/article/details/51692450)