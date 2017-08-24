---
layout:     post
title:      "Charles 抓取HTTPS数据包"
subtitle:   "HTTP/HTTPS抓包"
date:       2017-08-09
author:     "vincent"
header-img: "img/post-bg-11-hack-tools.jpg"
catalog: true
tags:
    - macOS
---

## 前言
[Charles](https://www.charlesproxy.com/) 是一款在Mac下常用的网络封包截取工具。Charles 可以将自己设置为系统的网络代理服务器，使得所有的网络请求都通过它来完成。这样，方便自己开发的时候进行接口调试和已经调试别的APP网络接口。。。

## 启用HTTP代理

![](/img/p-charles/charles-set.png)
这里启用 Charles 的代理，设置代理IP 为 `8888`

打开终端输入 ifconfig 查看当前的局域网IP

```
ifconfig
```
![](/img/p-charles/ifconfig.png)

然后将手机连入同一个Wi-Fi, 在Wi-Fi的 HTTP代理中设置为电脑的IP地址和端口。

Charles弹出确认框，点击Allow按钮即就可以愉快的获取到数据包信息啦。

## 如何使用HTTPS代理

#### 电脑端设置

想要抓取https的包的话，需要使用Charles自己的CA证书并进行
![](/img/p-charles/charles-https-set.png)
打开钥匙串，点击证书详情，设置为始终信任
![](/img/p-charles/chain-set.png)

#### 手机端设置

![](/img/p-charles/charles-https-set-ios.png)

如果你已经将手机的网络代理设置 Charles，那么可以直接在浏览器中输入网址 `charlesproxy.com/getssl` ,会提示安装证书描述文件:

![](/img/p-charles/iphone-profile.png)

安装证书
点击安装即可，如果出现的不是这个界面，那么把链接换成 https://www.charlesproxy.com/documentation/additional/legacy-ssl-proxying/，点击安装 itself 后面的 here 就可以了。

设置监听端口

![](/img/p-charles/charles-https-set2.png)

这里是设置所有的地址的 443 端口都进行代理。如果只抓取部分，也可以进行单独的地址设置。

现在就可以愉快的玩耍啦~ 以知乎为例

![](/img/p-charles/charles-https-result-zhihu.png)


## 参考学习
1. [iOS开发工具——网络封包分析工具Charles](http://www.infoq.com/cn/articles/network-packet-analysis-tool-charles)
2. [charles https抓包](http://www.cnblogs.com/chenlogin/p/5849471.html)



