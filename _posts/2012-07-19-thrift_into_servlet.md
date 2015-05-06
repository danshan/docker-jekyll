---
layout: post
title: thrift嵌入servlet
date: 2012-07-19 17:22
description: "thrift中有个bug, 在收到随机上传的数据是会OutOfMemory, 服务直接crash掉.<br/>
详见: <https://issues.apache.org/jira/browse/THRIFT-601><br/>
测试: telnet到服务端口, 随便输入什么, 会抛出**Connection closed by foreign host**. 我现在的解决方案是, 把thrift嵌入到servlet中"
tags: [thrift, servlet, java]
image:
  feature: abstract-5.jpg
  credit: dargadgetz
  creditlink: http://www.dargadgetz.com/ios-7-abstract-wallpaper-pack-for-iphone-5-and-ipod-touch-retina/
---

thrift中有个bug, 在收到随机上传的数据是会OutOfMemory, 服务直接crash掉.

详见: <https://issues.apache.org/jira/browse/THRIFT-601>

测试: telnet到服务端口, 随便输入什么, 会抛出**Connection closed by foreign host**.

我先在的解决方案是, 把thrift嵌入到servlet中:

{% highlight java%}
import org.apache.thrift.server.TServlet;

import pptv.spider.thrift.SpiderService;

public class SpiderServlet extends TServlet {
    public SpiderServlet() {
        super(new SpiderService.Processor(new SpiderServiceImpl()),
                new TBinaryProtocol.Factory());
    }
}
{% endhighlight %}

在编写client端时, 把Client.java中的

{% highlight java%}TTransport transport = new TSocket("localhost", 8080);{% endhighlight %}
改为
{% highlight java%}TTransport transport = new THttpClient("http://localhost:8080/servlet");{% endhighlight %}
