---
layout:     post
title:      "非越狱iOS逆向微信"
subtitle:   "自动抢红包，消息防撤回，修改微信运动步数"
date:       2017-03-03
author:     ""
header-img: "img/post-bg-5-reverse-wechat.jpg"
catalog: true
tags:
    - iOS
    - 逆向工程
---


> - 本文参考学习链接为： 
> [buginux](https://github.com/buginux/WeChatRedEnvelop)
>
> - 《 iOS 应用逆向工程》第二版

鉴于`《iOS逆向工程》`这本书其实买了很久，但是又断断续续的荒废了。看到 [buginux](https://github.com/buginux/WeChatRedEnvelop) 写的这篇文章后，果断又尝试起来。
由于目前手上没有能越狱越狱的手机，打包尝试起来特别麻烦。好在最后还是完成了。上图。

<img src="/img/reverse_wechat/result.jpg">

```
PS：目前最新的 6.5.5 版本红包并不能使用。
```


## 1.获取砸壳后的微信ipa
有两种方法
1. 通过 [Clutch](https://github.com/KJCracks/Clutch) 对越狱手机上的应用砸壳
2. 直接在 PP助手上下载

由于手里没有越狱的手机，所以就直接在 PP助手上下载了。
将下载后的 ``wechat.ipa`` 解压
```
$ unzip wechat.ipa -d wechat
```

## 2.使用 class-dump 导出微信头文件

#### 2.1 下载 class-dump 

```
$ https://code.google.com/archive/p/networkpx/downloads
```
1.1 解压并拷入到 /usr/bin/

```
$ tar -zxvf class-dump-z_0.2a.tar.gz
$ sudo cp mac_x86/class-dump-z /usr/bin/
```

#### 2.1.1 或者下载安装 ``OpenDev`` 环境。

```
class-dump已经包含在openDev中,openDev 存放文件夹opt/IOSOpenDev/bin 中,

并在/Users/vincent/bash_profile 注册了系统变量 路径
```

#### 2.2 导出 ``.h`` 头文件

可执行文件位置在
```
~/wechat/Payload/WeChat.app/WeChat
```
拷贝出来执行

```
$ class-dump
-H
WeChat
-o
heads
```
1. WeChat 是应用的可执行文件的路径
2. headers 是存放dump出来头文件的文件夹路径

## 3. 准备 dylib 动态链接库
将 [WeChatRedEnvelop](https://github.com/huanglins/WeChatRedEnvelop) clone 下来。执行 ``make`` , dylib 文件在 ``WeChatRedEnvelop/.theos/obj/debug/WeChatRedEnvelop.dylib``

```
$ git https://github.com/huanglins/WeChatRedEnvelop
$ cd WeChatRedEnvelop
make

$ cp .theos/obj/debug/WeChatRedEnvelop.dylib ~/Desktop # 注意是 .theos 目录，这是个隐藏目录
```

#### 3.1 修改动态链接库依赖项
使用 macOS 自带的 ``otool`` 工具检查 dylib 的依赖项

```
$ otool -L WeChatRedEnvelop.dylib

WeChatRedEnvelop2.dylib (architecture armv7):
	/Library/MobileSubstrate/DynamicLibraries/WeChatRedEnvelop.dylib (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
	/System/Library/Frameworks/Foundation.framework/Foundation (compatibility version 300.0.0, current version 1349.13.0)
	/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation (compatibility version 150.0.0, current version 1348.22.0)
	/System/Library/Frameworks/UIKit.framework/UIKit (compatibility version 1.0.0, current version 3600.6.21)
	/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 307.4.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1238.0.0)
WeChatRedEnvelop2.dylib (architecture arm64):
	/Library/MobileSubstrate/DynamicLibraries/WeChatRedEnvelop.dylib (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
	/System/Library/Frameworks/Foundation.framework/Foundation (compatibility version 300.0.0, current version 1349.13.0)
	/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation (compatibility version 150.0.0, current version 1348.22.0)
	/System/Library/Frameworks/UIKit.framework/UIKit (compatibility version 1.0.0, current version 3600.6.21)
	/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 307.4.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1238.0.0)
```
修改 ``/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate`` 链接地址到 ``libsubstrate.dylib``

```
$ install_name_tool -change /Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate 
@loader_path/libsubstrate.dylib WeChatRedEnvelop.dylib
```

> PS：libsubstrate.dylib 是越狱环境 MobileSubstrate 提供动态注入的一个链接库


## 4 将动态链接库注入到二进制文件中

#### 4.1 将 ``libsubstrate.dylib`` 和 ``WeChatRedEnvelop.dylib`` 拷贝到WeChat.app中

```
$ cp libsubstrate.dylib WeChatRedEnvelop.dylib wechat/Payload/WeChat.app
```
	
#### 4.2 使用开源的 [optool](https://github.com/alexzielenski/optool) 工具
编译安装 ``optool`` 工具
	
```
# 因为 optool 添加了 submodule，因为需要使用 --recuresive 选项，将子模块全部 clone 下来
$ git clone --recursive https://github.com/alexzielenski/optool.git
$ cd optool
$ xcodebuild -project optool.xcodeproj -configuration Release ARCHS="x86_64" build
```
	
#### 4.3 optool 注入

```
$ /path/to/optool install -c load -p "@executable_path/WeChatRedEnvelop.dylib" 
-t 
wechat/Payload/WeChat.app/WeChat
```

## 5. 打包，重新签名
打包和重新签名可以直接使用图形化操作工具 [ios-app-signer](https://github.com/DanTheMan827/ios-app-signer) 来完成。

> 需要使用开发者证书 ~~~~(>_<)~~~~

![](/img/p-reverse_wechat/ios-app-signer.png)

点击 start 后，指定保存路径，iOS App Signer 就会帮你搞定所有事情。

## 6. 安装
使用 Xcode 菜单 - Window - Devices 中打开设置窗口 
![](/img/reverse_wechat/xcode.png)

## End










