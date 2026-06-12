---
layout:     post
title:      "CocoaPods 制作公有库和私有库实践"
subtitle:   "公有库、私有库制作"
date:       2018-11-29
author:     "vincent"
header-img: "img/post-bg-18-mysql-slave.jpg"
header-style: text
catalog: true
tags:
    - iOS
    - CocoaPods
---

## 制作公有库

公有库就是我们通过官方的 CocoaPods 能直接搜索并使用的库。比如你可以直接搜索 `VHLNavigation` 并添加到项目中进行使用
```
pod search VHLNavigation
```

你可以直接下载 [VHLNavigation](https://github.com/huanglins/VHLNavigation) 作为参照进行修改。

#### podspec
首先我们在项目目录下创建 Podspec 文件
```
pod spec create VHLNavigation
```
之后会生成一个 `.podspec` 后缀的文件，该文件

`.podspec` 模板
```
Pod::Spec.new do |s|
  s.name         = "VHLNavigation" # 项目名称
  s.version      = "0.0.1"         # 版本号 与 你仓库的 标签号 对应
  s.license      = { :type => "MIT", :file => "LICENSE" }  # 开源证书
  s.summary      = "VHLNavigation" # 项目简介

  s.homepage     = "https://github.com/huanglins/VHLNavigation.git" # 仓库的主页
  s.source       = { :git => "https://github.com/huanglins/VHLNavigation.git", :tag => s.version } # 你的仓库地址，不能用SSH地址
  s.source_files = "VHLNavigation/*.{h,m}" # 你代码的位置， VHLNavigation/*.{h,m} 表示 VHLNavigation 文件夹下所有的.h和.m文件。或 VHLNavigation/**/*.{h,m}
  s.requires_arc = true                     # 是否启用ARC
  s.platform     = :ios, "8.0"              # 平台及支持的最低版本
  # s.frameworks   = "UIKit", "Foundation"  # 支持的框架
  # s.dependency   = "AFNetworking"         # 依赖库
  
  # User
  s.author             = { "Vincent" => "gvincent@163.com" } # 作者信息
  s.social_media_url   = "https://github.com/huanglins"      # 个人主页

end
```

设置完后将项目提交到 git 地址，并打上标签。**注意：打的标签(tag) 需要和 podspec 里面的 s.version 一致，不然提交到 CocoaPods 会报错，找不到相应版本。**

#### 提交代码到远程仓库并打包

```
# 提交代码
git add .
git commit -m "add: VHLNavigation.podspc"
git push -u origin master
# 打标签
git tag -a 0.0.1 -m "version 0.0.1"
git push --tag
```

#### 验证 podspec 文件的有效性

```
pod spec lint VHLNavigation.podspec --verbose --allow-warnings
```

验证成功后输出：
![-w936](/img/p-cocoapods/15434563020472.jpg)

#### 通过 pod trunk 提交

没有 trunk 账号的话，先进行注册：

```
pod trunk register gvincent@163.com `Vincent`
```
然后去邮箱里确认链接，确认后在终端中验证账号信息：
```
pod trunk me
```

验证信息如下：
![-w937](/img/p-cocoapods/15434568911691.jpg)

**提交到 CocoaPods trunk**
```
pod trunk push VHLNavigation.podspec --allow-warnings
```

提交成功后，通过 pod 搜索该库：
```
pod search VHLNavigation
```

![-w938](/img/p-cocoapods/15434569020017.jpg)

## 制作私有库
私有库是相对于公有库而言的，就是存放那些我们组内使用的共用代码，但是又不能公开出来的代码库，这时就需要使用到私有库了。

#### 创建私有库地址

首先我们先创建一个私有的 git 仓库地址，用来存储我们私有库的索引集合。这里我使用的是自己搭建的 [gogs](https://gogs.io/) git server。

![-w865](/img/p-cocoapods/15434569131054.jpg)


然后将该仓库添加到本地
```
pod repo add VHLRepo http://xx.xx.cn/xx/VHLRepo.git(自己的私有库 git 地址)
```

添加成功后，在 `~/.cocoapods/repos` 下可以看到刚添加的仓库文件夹

![-w740](/img/p-cocoapods/15434569220669.jpg)


查看其中一个仓库下的文件夹可以发现，里面存放的是该第三方库的版本索引。
![-w749](/img/p-cocoapods/15434569294345.jpg)


#### 发布私有库代码到私有库地址

将代码推送到私有库地址
```
pod repo push VHLRepo VHLNavigation.podspec
```
这时候我们可以在本地的仓库里面看到自己添加的库的文件夹，但这时私有库的信息只是本地的，远端的私有库集合里面并没有保存我们这一份第三方库索引，所有我们也需要将版本所有更新同步到远端私有库地址。

首先，将我们的私有仓库 clone 到本地，之后从 `~/.cocoapods/repos/VHLRepo` 中拷贝已经发布的第三方库索引到文件夹中。最后将更新到 git：

```
git add .
git commit -m "add VHLNavigation"
git push -u origin master
```

#### 使用私有库

在 `Podfile` 中添加私有库地址
```
# 指定私有库地址
source 'http://xx.xx.cn/vincent/VHLRepo.git
```
添加私有组件
```
pod 'VHLNavigation'
```

![-w993](/img/p-cocoapods/15434569378498.jpg)

再执行 `pod update` 就能使用我们私有库中的代码了。

# 参考学习

[如何发布自己的开源框架到CocoaPods](https://www.jianshu.com/p/2489a554a453)

[CocoaPods 私有仓库的创建](https://www.jianshu.com/p/0c640821b36f)
