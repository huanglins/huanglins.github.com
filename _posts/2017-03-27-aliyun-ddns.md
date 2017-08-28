---
layout:     post
title:      "阿里云DNS动态解析"
subtitle:   "DDNS"
date:       2017-03-27
author:     "vincent"
header-img: "img/post-bg-8-aliyun-ddns.jpg"
catalog: true
tags:
    - Python
---

想要通过域名直接访问路由器的公网IP，但是路由器的外网IP不是固定的，每次重启路由器都会改变。于是想要实现阿里云的DDNS(动态解析)。

好在阿里云提供了 SDK 可供我们使用，这里使用python来操作。[python-sdk](https://develop.aliyun.com/sdk/python?spm=5176.7926450.210367.2.Xov5Bp)

## 准备



#### 安装 python sdk
首先需要在当前机器上安装阿里云的 python SDK

```
pip install aliyun-python-sdk-alidns
```

因为这里只需要使用它的 dns 功能，需要其他的功能可以查看 [阿里云 python-sdk 列表](https://help.aliyun.com/document_detail/30003.html)

#### Access Key

[Access Key管理](https://ak-console.aliyun.com/#/accesskey)

1. Access Key ID
2. Access Key Secret 

#### 添加一条域名解析

添加一条A记录，主机记录可以为你的二级域名，例如： `xx.vincents.cn`。记录值随便写 `8.8.8.8`，因为后面会根据实际的IP进行动态更改。

## 使用阿里云的 python SDK

通过脚本更新DNS记录需要几个关键的信息，

1. 一级域名（你的域名）
2. 主机记录（你的二级域名）
3. 记录值 （你的机器的IP地址）
4. 记录ID （这条解析记录的ID）
5. 记录TTL （这条解析记录的生存时间）

#### 获取当前机器的IP

可以通过访问 [ip.cn](ip.cn)这个网站，获取本机的IP。
在终端中输入

```
curl -s ip.cn
```

结果为：

```
Vincents-iMac:~ vincent$ curl -s ip.cn
当前 IP：xx.xx.xxx.xxx 来自：重庆市 联通
```

python code:

```
"""
通过 ip.cn 获取当前主机的外网IP
"""
def get_my_publick_ip():
    get_ip_method = os.popen('curl -s ip.cn')
    get_ip_responses = get_ip_method.readlines()[0]
    get_ip_pattern = re.compile(r'\d+\.\d+\.\d+\.\d+')
    get_ip_value = get_ip_pattern.findall(get_ip_responses)
    return get_ip_value
```

#### 获取解析记录ID

```
"""
获取域名的解析信息
"""
def check_records(dns_domain):
    clt = client.AcsClient(access_key_id, access_key_secret, 'cn-hangzhou')
    request = DescribeDomainRecordsRequest.DescribeDomainRecordsRequest()
    request.set_DomainName(dns_domain)
    request.set_accept_format(rc_format)
    result = clt.do_action(request)
    result = json.JSONDecoder().decode(result)
    return result
```

#### 根据解析记录ID查询上一次的记录值
```
"""
根据域名解析记录ID查询上一次的IP记录
"""
def get_old_ip(record_id):
    clt = client.AcsClient(access_key_id,access_key_secret,'cn-hangzhou')
    request = DescribeDomainRecordInfoRequest.DescribeDomainRecordInfoRequest()
    request.set_RecordId(record_id)
    request.set_accept_format(rc_format)
    result = clt.do_action(request)
    result = json.JSONDecoder().decode(result)
    result = result['Value']
    return result
```

#### 更新解析记录
```
"""
更新阿里云域名解析记录信息
"""
def update_dns(dns_rr, dns_type, dns_value, dns_record_id, dns_ttl, dns_format):
    clt = client.AcsClient(access_key_id, access_key_secret, 'cn-hangzhou')
    request = UpdateDomainRecordRequest.UpdateDomainRecordRequest()
    request.set_RR(dns_rr)
    request.set_Type(dns_type)
    request.set_Value(dns_value)
    request.set_RecordId(dns_record_id)
    request.set_TTL(dns_ttl)
    request.set_accept_format(dns_format)
    result = clt.do_action(request)
    return result
```

## 完整脚本
```
#!/usr/bin/env python
# -*- coding: utf-8 -*-

import json
import os
import re
from datetime import datetime

from aliyunsdkcore import client
from aliyunsdkalidns.request.v20150109 import DescribeDomainRecordsRequest
from aliyunsdkalidns.request.v20150109 import DescribeDomainRecordInfoRequest
from aliyunsdkalidns.request.v20150109 import UpdateDomainRecordRequest

# 阿里云 Access Key ID
access_key_id = "xxxxx"
# 阿里云 Access Key Secret
access_key_secret = "xxxxxxxx"
# 阿里云 一级域名
rc_domain = 'xxx.cn'
# 返回内容格式
rc_format = 'json'

"""
获取域名的解析信息
"""
def check_records(dns_domain):
    clt = client.AcsClient(access_key_id, access_key_secret, 'cn-hangzhou')
    request = DescribeDomainRecordsRequest.DescribeDomainRecordsRequest()
    request.set_DomainName(dns_domain)
    request.set_accept_format(rc_format)
    result = clt.do_action(request)
    result = json.JSONDecoder().decode(result)
    return result

"""
根据域名解析记录ID查询上一次的IP记录
"""
def get_old_ip(record_id):
    clt = client.AcsClient(access_key_id,access_key_secret,'cn-hangzhou')
    request = DescribeDomainRecordInfoRequest.DescribeDomainRecordInfoRequest()
    request.set_RecordId(record_id)
    request.set_accept_format(rc_format)
    result = clt.do_action(request)
    result = json.JSONDecoder().decode(result)
    result = result['Value']
    return result

"""
更新阿里云域名解析记录信息
"""
def update_dns(dns_rr, dns_type, dns_value, dns_record_id, dns_ttl, dns_format):
    clt = client.AcsClient(access_key_id, access_key_secret, 'cn-hangzhou')
    request = UpdateDomainRecordRequest.UpdateDomainRecordRequest()
    request.set_RR(dns_rr)
    request.set_Type(dns_type)
    request.set_Value(dns_value)
    request.set_RecordId(dns_record_id)
    request.set_TTL(dns_ttl)
    request.set_accept_format(dns_format)
    result = clt.do_action(request)
    return result

"""
通过 ip.cn 获取当前主机的外网IP
"""
def get_my_publick_ip():
    get_ip_method = os.popen('curl -s ip.cn')
    get_ip_responses = get_ip_method.readlines()[0]
    get_ip_pattern = re.compile(r'\d+\.\d+\.\d+\.\d+')
    get_ip_value = get_ip_pattern.findall(get_ip_responses)
    return get_ip_value

def write_to_file(new_ip):
    time_now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    write_log = open('aliyun_ddns.txt', 'a')
    write_log.write(time_now + ' ' + str(new_ip) + '\n')
    return

if __name__ == '__main__':
    # # 之前的解析记录
    old_ip = ""
    record_id = ""
    dns_records = check_records(rc_domain)
    for record in dns_records["DomainRecords"]["Record"]:
        if record["Type"] == 'A' and record["RR"] == 'q':
            record_id = record["RecordId"]
            print "q.vincents.cn recordID is %s" % (record_id)
            if record_id != "":
                old_ip = get_old_ip(record_id)
               
    old_ip = get_old_ip(record_id)
    # 获取主机当前的IP
    now_ip = get_my_publick_ip()[0]
    print "now host ip is %s, dns ip is %s" % (now_ip, old_ip)

    if old_ip == now_ip:
        print "The specified value of parameter Value is the same as old"
    else:
        rc_rr = 'q'                 # 解析记录
        rc_type = 'a'               # 记录类型, DDNS填写A记录
        rc_value = now_ip           # 新的解析记录值
        rc_record_id = record_id    # 记录ID
        rc_ttl = '1000'             # 解析记录有效生存时间TTL,单位:秒

        print update_dns(rc_rr, rc_type, rc_value, rc_record_id, rc_ttl, rc_format)

        write_to_file(now_ip)

```

## crontab 定时运行

```
crontab -e
```

```
*/10 * * * * /usr/bin/python aliyun_ddns.py /dev/null 1>/dev/null
```

其中脚本存放路径替换为自己的实际路径

#### ** crontab 定时重启服务器

由于个人使用的服务器配置一般都不高，重启服务器又能释放一些占用的内存。所以在凌晨定时重启服务器还是很有必要的。亲测，自己1G的内存，使用一段时间省了100M左右的内存可以使用，重启后，又变成600M多了。2333...

```
crontab -e
```

```
# 凌晨5点重启一次服务器
0 5 * * * /sbin/reboot
```

查看系统重启记录

```
last reboot
```
![](/img/p-aliyun-ddns/reboot_result.png)


## 参考学习
1. [通过python将阿里云DNS解析作为DDNS使用](https://enginx.cn/2016/08/22/%E9%80%9A%E8%BF%87python%E5%B0%86%E9%98%BF%E9%87%8C%E4%BA%91dns%E8%A7%A3%E6%9E%90%E4%BD%9C%E4%B8%BAddns%E4%BD%BF%E7%94%A8.html)
2. [通过阿里云域名动态解析 IP 地址](https://www.v2ex.com/t/249694)



