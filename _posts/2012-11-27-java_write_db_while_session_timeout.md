---
layout: post
title: jsp解决session过期时写入数据库操作
date: 2012-11-27 14:00
description: "背景如下: <br/>
我在做一个系统的时候希望实现当用户点击jsp页面上的注销按钮时实现在数据库中保存用户注销的时间. 另外如果用户没有正常退出, 则在session超时时自动记录超时时候的时间."
category: Tech
tags: [java, session, database, j2ee]
---

背景如下: 

我在做一个系统的时候希望实现当用户点击jsp页面上的注销按钮时实现在数据库中保存用户注销的时间. 另外如果用户没有正常退出, 则在session超时时自动记录超时时候的时间.

仿照找到的关于利用**HttpSessionListener**实现在线人数统计的方法来处理: 

对每一个正在访问的用户, J2EE应用服务器会为其建立一个对应的**HttpSession**对象. 当一个浏览器第一次访问网站的时候, J2EE应用服务器会新建一个HttpSession对象, 并触发HttpSession创建事件, 如果注册了HttpSessionListener事件监听器, 则会调用**HttpSessionListener**事件监听器的`sessionCreated`方法. 

相反，当这个浏览器访问结束超时的时候, J2EE应用服务器会销 毁相应的HttpSession对象, 触发HttpSession销毁事件, 同时调用所注册**HttpSessionListener**事件监听器的`sessionDestroyed`方法. 

可见, 对应于一个用户访问的开始和结束, 相应的有`sessionCreated`方法和`sessionDestroyed`方法执行. 因此, 我们只需在**HttpSessionListener**实现类的`sessionDestroyed`方法中让其执行数据库的更新操作就可以了. 下面是示例代码: 

{% highlight java %}
package com.shanhh.session;

import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;
import libms.service.UserServiceImpl;

public class UserOnlineListener implements HttpSessionListener {
    
    private static long userId = 0;
    
    public static void setUserId(long id) {
        userId = id;
    }

    public void sessionCreated(HttpSessionEvent event) {
    }

    public void sessionDestroyed(HttpSessionEvent event) {
        if (userId > 0) {
            // TODO 这里写更新数据库的操作
        }
    }
}
{% endhighlight %}

在web.xml文件中注册一个监听器: 

{% highlight xml %}
<listener>
    <listener-class>com.online.OnlineCountListener</listener-class>
</listener>
{% endhighlight %}

在用户登录的时候, 把用户的id使用`UserOnlineListener.setUserId(id)`的方法保存下来. 当用户点击注销按钮的时候, 调用`session.invalidate()`的方法清空session, 就会触发监听器`sessionDestroyed(HttpSessionEvent event)`方法了, 同样, 如果用户非正常退出, 则在session超时的时候, 也会出发该方法.

