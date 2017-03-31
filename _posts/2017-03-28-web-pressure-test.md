---
layout:     post
title:      "Web服务器压力测试工具 - webbench,Siege"
subtitle:   "webbench,Siege"
date:       2017-03-28
author:     "vincent"
header-img: "img/post-bg-9-webbench.jpg"
catalog: true
tags:
    - web服务器
---

> Webbench是有名的网站压力测试工具，它是由 Lionbridge公司开发。

因为之前公司网站的服务器各种拒绝连接，想要测试一下网站的QPS(每秒查询率)，看下大概能到多少并发，于是找到这个工具。但是结果果然超乎想象，2333...

## Webbench

webbench是有名的网站压力测试工具，最多可以模拟3万个并发连接去测试网站的负载能力。

webbench能测试处在相同硬件上，不同服务的性能以及不同硬件上同一个服务的运行状况。

webbench的标准测试可以向我们展示服务器的两项内容：每秒钟相应请求数和每秒钟传输数据量。

#### MAC安装

在Mac环境下，通过`brew`进行安装

```
brew install ctags # 依赖安装

wget http://blog.zyan.cc/soft/linux/webbench/webbench-1.5.tar.gz

tar -zxvf webbench-1.5.tar.gz

cd webbench-1.5

mkdir -pv /usr/local/man/man1 # 关键

sodu make && sudo make install # sudo 权限因为需要创建文件夹

```

###### 使用

```
webbench -c 100 -t 30 [URL]
```

参数说明：`-c`表示并发数，`-t`表示时间(秒)

#### 相关命令

```

webbench [option]... URL

  -f|--force               压测时不等待服务端返回
  -r|--reload              Send reload request - Pragma: no-cache.
  -t|--time <sec>          压测时间/s, 默认30/s
  -p|--proxy <server:port> 使用代理来进行请求
  -c|--clients <n>         并发数量默认1个
  -9|--http09              使用HTTP/0.9 协议请求
  -1|--http10              使用HTTP/1.0 协议请求
  -2|--http11              使用HTTP/1.1 协议请求
  --get                    使用GET方式请求
  --head                   使用 HEAD 方式请求
  --options                Use OPTIONS request method.
  --trace                  Use TRACE request method.
  -?|-h|--help             This information.
  -V|--version             显示当前版本

```

#### 使用结果

![](/img/webbench/result.png)

貌似只有 0 failed 访问才不会有太大影响。其他或多或少都会有影响。 神经病的马赛克。~

## Siege

一款开源的压力测试工具，可以根据配置对一个WEB站点进行多用户的并发访问，记录每个用户所有请求过程的相应时间，并在一定数量的并发访问下重复进行。

* 最新版本：[http://download.joedog.org/siege/siege-latest.tar.gz](http://download.joedog.org/siege/siege-latest.tar.gz)
* 源代码：[https://github.com/JoeDog/siege.git](https://github.com/JoeDog/siege.git)

#### mac 安装

```
# wget http://download.joedog.org/siege/siege-latest.tar.gz
# tar -zxvf siege-latest.tar.gz
# cd siege-latest/
# ./configure
# make && make install
```

#### 相关命令

```
-V, --version             VERSION, prints the version number.
  -h, --help                HELP, prints this section.
  -C, --config              CONFIGURATION, show the current config.
  -v, --verbose             VERBOSE, prints notification to screen.
  -q, --quiet               QUIET turns verbose off and suppresses output.
  -g, --get                 GET, pull down HTTP headers and display the
                            transaction. Great for application debugging.
  -c, --concurrent=NUM      CONCURRENT users, default is 10
  -i, --internet            INTERNET user simulation, hits URLs randomly.
  -b, --benchmark           BENCHMARK: no delays between requests.
  -t, --time=NUMm           TIMED testing where "m" is modifier S, M, or H
                            ex: --time=1H, one hour test.
  -r, --reps=NUM            REPS, number of times to run the test.
  -f, --file=FILE           FILE, select a specific URLS FILE.
  -R, --rc=FILE             RC, specify an siegerc file
  -l, --log[=FILE]          LOG to FILE. If FILE is not specified, the
                            default is used: PREFIX/var/siege.log
  -m, --mark="text"         MARK, mark the log file with a string.
  -d, --delay=NUM           Time DELAY, random delay before each requst
                            between .001 and NUM. (NOT COUNTED IN STATS)
  -H, --header="text"       Add a header to request (can be many)
  -A, --user-agent="text"   Sets User-Agent in request
  -T, --content-type="text" Sets Content-Type in request
```

#### 使用

100个并发访问 `http://www.baidu.com`，并重复20次

```
siege -c 100 -r 20 http://www.baidu.com
```

在 urls.txt 中列出所有网址

```
siege -c 100 -r 20 -f urls.txt  
```

随机选取 urls.txt 中列出的网址

```
siege -c 100 -r 20 -f urls.txt -i
```

不等待返回结果,100个并发随机选取urls.txt重复请求20个

```
siege -c 2000 -r 100 -f urls.txt -i -b  
```

指定 http 请求头请求

```
siege -H "Content-Type:application/json" -c 100 -r 20 -f urls.txt -i -b  
```

POST 请求

```
siege -c 100 -r 20 http://www.baidu.com/ POST p1=v1&p2=v2  
```

#### Siege 输出结果说明

![](/img/web-test-tool/siege.png)


------- | -------
Transactions | 总共测试次数 
Availability | 成功次数百分比 
Elapsed time | 总共耗时多少秒 
Data transferred | 总共数据传输
Response time | 等到响应耗时
Transaction rate | 平均每秒处理请求数
Throughput | 吞吐率
Concurrency | 最高并发
Successful transactions | 成功的请求数
Failed transactions | 失败的请求数

## END

性能测试工具目前最常见的有以下几种：`ab`、`webbench`,`http_load`、`siege`，后面有用到再来试试。

* [Webbench 一款 Linux 下的压力测试工具 for Mac](http://www.open-open.com/news/view/d6dff4)
* [记录：Web服务器压力测试工具WebBench、Siege](https://www.skyf.org/webbench-web-test-tools/)


