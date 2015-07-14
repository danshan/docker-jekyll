---
layout: post
title: "记引入 drools 后的一次线上 OOM 问题的处理"
date: 2015-05-24 16:46
description: "这是在点评刚刚引入drools的时候, 一次线上事故处理的情况, 造成了线上结婚移动端接口的 OOM"
tags: [java, exception, drools]
image:
  feature: abstract-2.jpg
  credit: dargadgetz
  creditlink: http://www.dargadgetz.com/ios-7-abstract-wallpaper-pack-for-iphone-5-and-ipod-touch-retina/
---

2015-04-15 11:53 接监控组报警, 发现 wedding-mobileapi-web 线上大量 502 error.
这个项目为结婚的移动客户端提供所有业务的接口.

最终排查原因是由于调用 drools 的 StatefulKnowledgeSession 对象没有调用dispose()方法释放内存(先简单类比与 mysql 的 connect最后要close)

首先自我检讨一下, 引用了drools包之后, 只是验证了线上的业务流程, 没有关注到这样的细节. 
下面说一下整个问题的排查过程, 供大家一起学习参考.

接警后先上cat 确认问题, 并发现很多dpsf timeout 异常.

<img src="{{ site.cdn }}/files/2015/05/drools-01.png{{ site.img }}">

这里存在两个疑点: 

    1. 如果是dpsf timeout造成, 那么应该是大面积的影响, 而不是针对单一业务.
    2. 这远远达不到运维说的每小时好几千的量.

于是直接跳板机到线上环境去看nginx日志.
通过这个命令来计数: 

{% highlight bash %}
cat wedding-mobileapi-web.access.log | grep -e "\s502\s" | wc -l
{% endhighlight %}

看到当时的量达到6000+(单机).

当时就想到既然nginx返回错误, 但是业务没有抛异常, 非常大的可能是由于gc导致的stoptheworld.
同时发现还有不少的499 的异常, 这个异常代码大家估计见得很少, 不是标准的http code.
499 是由于客户端在超时的时间范围内无法获得服务器返回, 而主动中断, 那么服务端的nginx会自己抛出499.

从上述几点去考虑, 最大的可能应该就是gc引起的.

于是先找运维dump一台服务器内存. 同时登录到zabbix去查看监控数据.

<img src="{{ site.cdn }}/files/2015/05/drools-02.png{{ site.img }}">

看到 10:20 左右, 线程数暴增.

<img src="{{ site.cdn }}/files/2015/05/drools-03.png{{ site.img }}">

Old Gen 也在相同时间点跑满了.

问题基本定位到时内存泄露造成, 下面是修复.

这次变更主要两个方面的修改

    1. @纪坤 对于线上502的bugfix
    2. @我 这里引用的 drools框架, 我自己怀疑就是我自己造成的. 所以先自查

由于dump出来的内存有3.6G, 拖到本地需要一个多小时, 所以直接肉眼看.
看到这样的代码:

<img src="{{ site.cdn }}/files/2015/05/drools-04.png{{ site.img }}">

我突然想到drools 文档中的关于 StatefulKnowledgeSession 的使用的一句话, 于是重新查了一下:

> After the application finishes using the session, though, it **MUST** call the dispose() method in order to free the resources and used memory.

好吧, 于是修改代码为

<img src="{{ site.cdn }}/files/2015/05/drools-05.png{{ site.img }}">

15:00 先找了一台机器上线, 观察了5分钟, 没有啥异常出现, 于是全面上线.

<img src="{{ site.cdn }}/files/2015/05/drools-06.png{{ site.img }}">

这是上线后的Old Gen, 其中14:00有个骤降, 是由于运维重启应用, 但是可以看重启后依然在飞速上涨. 15:00fix上线, 开始缓慢上涨, 基本与正常现象相同.

16:00 @波总 完成 dump文件的分析:

<img src="{{ site.cdn }}/files/2015/05/drools-07.png{{ site.img }}">

看到确实是statefulSession导致的泄露, 问题得到确认.

以上是整个事故的发现和解决过程. 从中得到的教训是: 

1. 一定要仔细看文档, 尤其是和内存相关的部分.
2. 出现问题不要急, 通过现象去分析可能造成的原因, 用排除法去过滤一些干扰. 然后逐一验证.
3. 擅于使用一些常用的运维工具, 可以帮忙快速确认问题. 尤其推荐zabbix. nagios 这样的监控
4. 了解一些常用的 linux 命令事半功倍.