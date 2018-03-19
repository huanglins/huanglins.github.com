---
layout:     post
title:      "iOS 西培学堂 - 绕过人脸识别"
subtitle:   "iOS逆向"
date:       2018-03-08
author:     "vincent"
header-img: "img/post-bg-15-reverse-xipeixuetang.jpg"
catalog: true
tags:
    - iOS
    - iOS 逆向
---


最近在学习驾照，考科目一的时候需要在 **西培学堂** 上面学习视频 1320 分钟。最主要的是每隔25分钟就要进行一次人脸识别验证，没有立即验证的话单次学习的时间就会失效。本着好好学习的态度，于是想看下能不能友好的进行人脸识别。..

#### 抓包测试

![](/img/p-xipeixuetang/uploadimage.png)
抓包测试发现，人脸识别是在本地进行校验的，识别成功后再将识别的结果图片上传到服务器进行保存，并记录时间。那么这样的话，我们就可以在本地将人脸识别绕过，并传一张假图片给服务器就行了(手动滑稽..)

#### 导出头文件

首先我们在 PP助手上下载已经脱壳的 IPA，然后导出所有头文件。

```
class-dump -H /xx/xx/tbtimingCount.app/tbtimingCount -o /Users/xx/Desktop/header
```

#### 分析测试

搜索 `face` 相关的文件
![](/img/p-xipeixuetang/search_face.png)

打开 Xcode 新建一个 [MonkeyDev](https://github.com/AloneMonkey/MonkeyDev) 工程，将 ipa 导入工程。

经测试，**TbCameraWalk** 这个文件用来处理学习计时和调用摄像头进行人脸识别的相关操作。
![](/img/p-xipeixuetang/file_source.png)

其中检测到需要人脸识别摄像头被调用时，会响应以下方法:
```
- (void)cwFaceInfoCallBack:(id)arg1;                                // 人脸识别结果
```
该文件中有一个人脸识别结果回调，返回一个图片信息，界面收到回调时将会调用接口上传人脸识别图片并计时。

![](/img/p-xipeixuetang/delegate_source.png)

检测完成，关闭人脸识别界面方法为：
```
- (void)liveDetectSucess;
```


#### 编码

![](/img/p-xipeixuetang/reverse_code.png)

在摄像头回调中直接将上面抓包的 Image Base64的数据，手动调用给 Delegate，测试发现后台服务器并没有再次进行图像比较。然后手动调用检测成功，关闭页面。






