---
layout:     post
title:      "CentOS 防火墙配置之 iptables和DDoS deflate"
subtitle:   "iptables详解和DDos deflate配置安装"
date:       2017-08-26
author:     "vincent"
header-img: "img/post-bg-12-iptables.jpg"
catalog: true
tags:
    - CentOS
    - Web服务器
---
## iptables
netfilter/iptables IP 信息包过滤系统是一种功能强大的工具，可用于添加、编辑和除去规则，这些规则是在做信息包过滤决定时，防火墙所遵循和组成的规则。这些规则存储在专用的信息包过滤表中，而这些表集成在 Linux 内核中。在信息包过滤表中，规则被分组放在我们所谓的链（chain）中。

netfilter 组件也称为内核空间（kernelspace），是内核的一部分，由一些信息包过滤表组成，这些表包含内核用来控制信息包过滤处理的规则集。
iptables 建立在 netfilter 架构基础上的一个包过滤管理工具，也称为用户空间（userspace），它使插入、修改和除去信息包过滤表中的规则变得容易。
iptables包含4个表，5个链。其中表是按照对数据包的操作区分的，链是按照不同的Hook点来区分的，表和链实际上是netfilter的两个维度。

#### 1.iptables 语法规则

```
iptables [-t 表] 大写选项子命令(-A) [规则号] 链名 匹配标准(-s xx.xx.xx.xx) -j 目标（规则）
```

**注意：所有表名必须小写，命令动作必须大写，链名必须大写，匹配标准必须小写，目标规则必须大写**

#### 2.iptables 表

------- | -------
filter | 一般的数据包过滤功能
nat | 用于nat(网络地址转换)功能（端口映射，地址映射等）
mangle | 用于对特定数据包进行修改
raw | 优先级最高，设置raw时一般是为了不再让iptables做数据包的链接跟踪处理，提高性能

表的处理优先级：raw > mangle > nat > filter

#### 3.iptables 链

------- | -------
PREROUTING | 数据包进入路由表之前
INPUT | 通过路由表后目的地为本机
FORWARDING | 通过路由表后，目的地不为本机
OUTPUT | 由本机产生，向外转发
POSTROUTIONG | 发送到网卡之前。

如图：
![](/img/p-iptables/iptables_chain.png)
iptables 中表和链的对应关系如下：
![](/img/p-iptables/iptables_chain1.png)

表 | 包含的规则链
------- | -------
filter| INPUT , FORWARD , OUTPUT
nat | PREROUTING , OUTPUT , POSTROUTING
mangle | PREROUTING , OUTPUT , POSTROUTING

#### 4.iptables 相关参数

##### 4.1.命令参数

------- | -------
-A | 向规则链中添加一条规则，默认被添加到末尾
-I | 插入一条规则，默认会被插入到首部
-T | 指定要操作的表，默认是 *filter*
-D | 从规则链中删除规则，可以指定序号或者匹配的规则来删除
-R | 进行规则替换
-F | 清空所选的链，重启后恢复
-N | 新建用户自定义规则链
-X | 删除用户自定义的规则链

##### 4.2.匹配标准参数

------- | -------
-p | 用来指定协议。可以是 tcp，udp，icmp等，也可以是数字的协议号
-s | 指定源地址
-d | 指定目的地址
-i | 进入接口
-o | 流出接口
--sport | 源端口
--dport | 目的端口，端口必须和协议一起来配合使用

##### 4.3.目标规则

------- | -------
-j | 采取的动作。ACCEPT(接收)，DROP(丢弃)，REJECT(拒绝)，
| RETURN(返回主键继续匹配)，REDIRECT(端口重定向)，
| MASQUERADE(地址伪装)，DNAT(目标地址转换)，SNAT(源地址转换)，MARK(打标签)

#### 5.iptables 实际操作

以上是 iptables 语法规则的相关参数和说明，现在让我们来实际操作使用一下。一般常用操作的是 `filter`表， `mangle` 和 `raw` 请自行 google 高级用法。

##### 5.1.基本使用

```
列出 iptables 规则
# iptables -L		# 默认选择 filter 表
# iptables -t nat -L

清除 内置规则
# iptables -F
# iptables -t nat -F

清除自定义规则
# iptables -X
# iptables -t nat -F 
```

##### 5.2.filter
```
禁止某个IP访问
# iptables -I INPUT -s xxx.xxx.xx.x -j DROP

服务器禁止被 ping
# iptables -A INPUT -p icmp -j DROP
禁止某个 IP ping 服务器
# iptables -A INPUT -p icmp -s xxx.xxx.xx.x -j DROP
只允许某个 IP ping 服务器
# iptables -I INPUT -p icmp -s xxx.xxx.xx.x -j ACCEPT

开启端口服务
# iptables -A OUTPUT -p udp -o eth0 --dport 53 -j ACCEPT
# iptables -A INPUT -p udp -i eth0 --sport 53 -j ACCEPT

开启转发功能
- 普通转发，假设 eth0 连接内网，eth1 连接公网。(必须要有2块网卡)
# iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT
- 只允许已建连接以及相关连接对内转发
# iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
- 允许对外转发
# iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT

允许 loopback 回环通讯
# iptables -A INPUT -i lo -p all -j ACCEPT
# iptables -A OUTPUT -o lo -p all -j ACCEPT

实例：当总连接数超过100时，启用 litmit/minute 限制
# iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
- litmit 25/minute 每分钟限制最大连接数为25
- litmit-burst 100 当总连接数超过100时，启动 limit/minute 限制
```

##### 5.3 nat

```
目的地址转换，映射内部地址
# iptables -t nat -A PREROUTING -i ppp0 -p tcp --dprot 81 -j DNAT --to 192.168.0.2:80
# iptables -t nat -A PREROUTING -i ppp0 -p tcp --dprot 81 -j DNAT --to 192.168.0.1-192.168.0.10

源地址转换，隐藏内部地址
# iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j SNAT --to 1.1.1.1
# iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j SNAT --to 1.1.1.1-1.1.1.10

地址伪装，动态ip的NAT（地址转换）
# iptables -t nat -A POSTROUTING -s 192.168.0.0/24 -j MASQUERADE
```
`masquerade` 和 `snat` 的主要区别在于，snat 是把源地址转换为固定的 IP 地址或者是地址池，而 masquerade 在 adsl 等方式拨号上网时候非常有用，因为是拨号上网所以网卡的外网IP经常变化，这样在进行地址转换的时候就要在每次都要修改转换策略里面的 ip，使用 masquerade 就很好的解决了这个问题，他会自己去探测外网卡获得的ip地址然后自动进行地址转换，这样就算外网获得的 ip 经常变化也不用人工干预了。

##### 5.4 删除规则

```
iptables -D chain rulenum [options]
```
chain 是链的意思，就是 INPUT FORWARD 之类的定语，rulenum 是该条规则的编号，从1开始。可以使用`iptables -L INPUT --line`列出指定的链的规则的编号来。然后通过编号删除
```
iptables -D INPUT 1
```

第二种办法是 `-A` 命令的映射，不过用 `-D` 替换 `-A` 。当你的链中规则很复杂，而你不想计算它们的编号的时候这就十分有用了。
也就是说，你如何一开始时用 `iptables -A.... `语句定义了一个规则，那么删除此条规则时直接用 `-D` 来代替 `-A`， 其余的都不变即可，而不需要什么编号了。

## DDoS deflate
DDos deflate 是一款免费的用来防御和减轻 DDos 攻击的脚本。它通过 `netstat` 监测跟踪与服务器创建了大量网络连接的IP地址，在监测到某个节点超过预设的限制时，该程序会通过 APF 或者 iptables 对这些 IP 进行一段时间内的禁止访问。

DDoS deflate官方网站：[http://deflate.medialayer.com/](http://deflate.medialayer.com/)

**如何确定是否受到DDoS攻击了呢?**

执行 *netstat* 命令
```
netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n
```
或者
```
netstat -ntu | awk '{print $5}' | cut -d: -f1 | sed -n '/[0-9]/p' | sort |
 uniq -c | sort -nr
```
下一段会过滤掉其中不是 IP 的一些记录，结果如下：
![](/img/p-iptables/netstat_result.png)
第一个表示每个IP当前的连接数，一般IP几十个以内都算比较正常。如果突然某个IP的连接数有成百上千个，那肯定就不正常了。

#### 1.安装 DDoS deflate

```
# cd /tmp
# wget http://www.inetbase.com/scripts/ddos/install.sh
# chmod 0700 install.sh
# ./install.sh
```
`分别是：1.下载文件，2.给文件添加权限，3.执行安装 `

#### 2.配置 DDoS deflate

文件安装目录位于 `/usr/local/ddos`，其中文件有：
* **ddos.conf**     	// 相关配置文件
* **ssos.sh**		  		// shell脚本
* **ignore.ip.list**	// ip白名单
* **LICENSE**				// 许可

`ddos.conf` 配置如下

```
##### Paths of the script and other files
PROGDIR="/usr/local/ddos"
PROG="/usr/local/ddos/ddos.sh"
IGNORE_IP_LIST="/usr/local/ddos/ignore.ip.list" # ip 地址白名单
CRON="/etc/cron.d/ddos.cron"	# 定时任务位置
APF="/etc/apf/apf"		# APF
IPT="/sbin/iptables"		# iptables

##### frequency in minutes for running the script
##### Caution: Every time this setting is changed, run the script with --cron
#####          option so that the new frequency takes effect
FREQ=1		# 检测时间间隔，默认为1分钟

##### How many connections define a bad IP? Indicate that below.
NO_OF_CONNECTIONS=150		# 一个IP下的最大连接数,超过就会屏蔽

##### APF_BAN=1 (Make sure your APF version is atleast 0.96)
##### APF_BAN=0 (Uses iptables for banning ips instead of APF)
APF_BAN=0	# 使用 APF还是iptables，推荐使用 iptables，将APF_BAN 改为0即可。
# APF 是基于 iptables 的防火墙

##### KILL=0 (Bad IPs are'nt banned, good for interactive execution of script)
##### KILL=1 (Recommended setting)
KILL=1		# 是否屏蔽禁止IP，默认。

##### An email is sent to the following address when an IP is banned.
##### Blank would suppress sending of mails
EMAIL_TO="1@vincents.cn"	# 当IP被屏蔽时给指定邮箱发送邮件。

##### Number of seconds the banned ip should remain in blacklist.
BAN_PERIOD=600			# 禁用IP时长,默认为600秒
```

`ddos.sh` 中，可以将第 117 行的内容修改为，就是上面那句 *netstat* 命令：
```
netstat -ntu | awk '{print $5}' | cut -d: -f1 | sed -n '/[0-9]/p' | sort |
 uniq -c | sort -nr
```

有文件内容更改后，执行：
```
# sh /usr/local/ddos/ddos.sh
```
会在`/etc/cron.d/`目录下生成一个定时任务`ddos.cron`。内容为：
```
0-59/1 * * * * root /usr/local/ddos/ddos.sh >/dev/null 2>&1
```
#### 3.测试

接下来你就可以使用压力测软件 [webbench,Siege](/2017/03/28/web-pressure-test/) 来进行测试实验了。我的测试结果如下， 通过 `webbench` 开启压力测试后，IP就立即被封禁，且很快就收到邮件,效果还是非常明显的。
![](/img/p-iptables/ddos_result.png)
ps: 为了让图片少占点位置，只有这么拼接一下了。将就看。。。

## 参考学习
1. [iptabls](http://www.cnblogs.com/argb/p/3535179.html)
2. [iptabls配置详解](http://www.liusuping.com/ubuntu-linux/iptables-firewall-setting.html)
3. [iptables四个表与五个链间的处理关系](http://www.linuxidc.com/Linux/2012-08/67505.htm)
4. [Shell实现的iptables管理脚本](https://yq.aliyun.com/ziliao/116528?spm=5176.8246799.0.0.JIvrMb)
5. [DDoS deflate - Linux下防御/减轻DDOS攻击](https://www.vpser.net/security/ddos-deflate.html)



