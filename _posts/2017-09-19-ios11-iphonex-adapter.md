---
layout:     post
title:      "iOS11/iPhone X 适配(填坑)指南"
subtitle:   "适配遇到的各种问题"
date:       2017-09-19
author:     "vincent"
header-img: "img/post-bg-14-ios11-iphonex-adapter.jpg"
catalog: true
tags:
    - iOS
---


## 适配 iOS11

#### 1. UITableView contentOffset 下移 20

```
if (@available(iOS 11.0, *)) {
	if ([self.tableView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
		self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
	}
}
```

## 适配 iPhone X


手机型号 | 屏幕尺寸 | 屏幕密度 | 开发尺寸 | 像素尺寸 | 倍图
------- | -------
4/4S | 3.5英寸 | 326ppi | 320x486 pt | 640x969 pt | @2x
5/5S/5C | 4英寸 | 326ppi | 320x568 pt | 640x1136 px | @2x
6/6S/7/8 | 4.7英寸 | 326ppi | 375x667 pt | 750x1334 px | @2x
6+/6S+/7+/8+ | 5.5英寸 | 401ppi | 414x736 pt | 1242*2208 px | @3x
X | 5.8英寸 | 458英寸 | 375x812 pt | 1125x2436 px | @3x


首先需要在 `Assets.xcassets` 中设置 iPhone X 的 `LaunchImage`。一张`1125*2436`的启动图。

![iPhone X](/img/p-ios11-adapter/iphonex_launch.png)

**iPhone X** 宏定义

```
#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? \
        CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
```

## 我的开源项目

各种导航栏
[VHLNavigation](https://github.com/huanglins/VHLNavigation)


