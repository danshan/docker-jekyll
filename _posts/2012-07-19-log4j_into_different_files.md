---
layout: post
title: log4j不同业务逻辑输出到不同的log文件
date: 2012-07-19 17:35
description: 场景设定为, A和B两个业务模块, 分别运行于不同的JVM环境下. A和B都要调用C模块, 现在需要实现的是, C模块根据不同的运行环境, 日志输出到不同的log文件.
category: Tech
tags: [java, log4j]
---

比如两个业务逻辑模块: A和B, 分别都会调用模块C, 分别处于不同的JVM下, 现在需要实现的是, 不同的业务输出到不同的日志文件.
以如下配置文件为例:

{% highlight properties%}
log4j.appender.R=org.apache.log4j.DailyRollingFileAppender
log4j.appender.R.File=/home/dan/runtime/epg/spider/log/spider.log
log4j.appender.R.layout=org.apache.log4j.PatternLayout
log4j.appender.R.layout.ConversionPattern=%d [%t]:%l %m%n
{% endhighlight %}

创建一个方法用于重定向log地址

{% highlight java %}
public class FileUtil {
    /**
     * 重定向log4j日志地址
     * @param ext
     */
    public static void redirectLogext(String ext) {
        Properties props = new Properties();
        try {
            InputStream istream = FileUtil.class.getResourceAsStream("/log4j.properties");
            props.load(istream);
            istream.close();
            props.setProperty("log4j.appender.R.File", props.getProperty("log4j.appender.R.File") + ext);
            PropertyConfigurator.configure(props);// 装入log4j配置信息
        } catch (IOException e) {
            LOG.error(e);
            return;
        }
    }
}
{% endhighlight %}

在需要重定向log的时候, 加入一行即可

{% highlight java %}
public class MyClass {
    
    private static final Logger logger = Logger.getLogger(MyClass.class);

    public static void main(String[] args) {
        FileUtil.redirectLogext(".checker");
        logger.info("this is MyClass");
    }
}
{% endhighlight %}
