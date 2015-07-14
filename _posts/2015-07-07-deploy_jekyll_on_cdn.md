---
layout: post
title: "将 Jekyll 的网站部署到七牛 CDN 上"
date: 2015-07-07 10:14
description: "通过七牛的 CDN 加速个人网站"
tags: [jekyll, cdn]
image:
  feature: abstract-4.jpg
  credit: dargadgetz
  creditlink: http://www.dargadgetz.com/ios-7-abstract-wallpaper-pack-for-iphone-5-and-ipod-touch-retina/
---

我的个人网站 [Dan's Workspace](http://www.shanhh.com) 是放在日本的 [AWS](http://aws.amazon.com/cn/) 上, 由于众所周知的原因, 国内访问起来有点吃力.

我这里是通过 [Jekyll](http://jekyllrb.com/) 搭建的个人网站. 这里考虑一些简单的免费的解决方案.

# 将一些 google 提供对的静态文件(比如字体, js库什么的)用国内的一些源去替换

通过浏览器抓包, 应该能看到不少请求时到 google 字体库的 _http://fonts.googleapis.com_, 或者一些 google 的公共资源库 _http://ajax.googleapis.com_. 国内访问很困难, 不过 360 提供了一个国内的 [前端公共库CDN服务](http://libs.useso.com/)

用法也非常简单, 全文搜索一下, 把调用的google的地址做个替换就行了, 别的地方都不变.

# 把静态文件放到 CDN 上

这里我使用的是 [七牛云存储](http://www.qiniu.com/), 新注册的免费体验用户不限时间, 而且对于个人站长来说基本也够用.

<img src="{{ site.cdn }}/files/2015/07/cdn-01.png{{ site.img }}">

首先 [注册新用户](https://portal.qiniu.com/signup), 并验证邮箱后重新登录.

<img src="{{ site.cdn }}/files/2015/07/cdn-02.png{{ site.img }}">

之后创建一个空间, 为你的空间起一个名字, 需要全局唯一. 注意下这个空间一定要设置为公开访问的, 不然别人无法访问.

<img src="{{ site.cdn }}/files/2015/07/cdn-03.png{{ site.img }}">

在 空间设置 -> 域名设置 里对七牛的cdn域名进行修改和记录.

<img src="{{ site.cdn }}/files/2015/07/cdn-04.png{{ site.img }}">

然后就是把我们的静态资源文件上传到七牛空间上. 因为 Jekyll 生成的网站整个都是静态的, 所以理论上 可以把整个网站都放上去, 对于体验账号, 只可以上传富媒体文件, 也就是 图片/css/js 之类的, 也就够用了.

一张一张上传肯定要疯, 还在七牛在 [developer.qiniu.com](http://developer.qiniu.com/) 提供了一个同步工具 [qrsync](http://developer.qiniu.com/docs/v6/tools/qrsync.html), 配置方法也非常简单, 把 **src** 指向 `jekyll build` 生成的 **_site** 文件夹.

上传成功的以后就能在内容管理中就能看到刚刚静态资源文件, 上传会保持原本的目录结构, 方便我们做迁移.

<img src="{{ site.cdn }}/files/2015/07/cdn-05.png{{ site.img }}">

最后, 我们修改原有的资源访问地址, 全文搜索一下, 基本地址应该都在 assets 或者 images 这样的文件夹.

如果之前的访问地址 为 _/assets/css/main.css_, 那么新的地址应该就是 _{cdn地址}/{qrsync前缀}/assets/css/main.css_.

这里介绍个偷懒的地方, 直接在 \_config.yaml 里新建一个包含cdn地址和qrsync前缀的值:

> cdn: "http://7xk6nq.com1.z0.glb.clouddn.com/blog"

那么在全文就可以使用 \{\{ site.cdn \}\} 进行使用.

# 其它 CDN 的解决方案

前面说的也差不多了, 最后介绍一个七牛提供的 开放静态资源 CDN, 有兴趣的前端开发朋友可以去看看 [http://www.staticfile.org/](http://www.staticfile.org/)

<img src="{{ site.cdn }}/files/2015/07/cdn-06.png{{ site.img }}">
