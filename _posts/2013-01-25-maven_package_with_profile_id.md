---
layout: post
title: Maven 根据不同的 profile 对不同的构建环境进行配置
date: 2013-01-25 19:27
description: "通过 maven 管理项目的时候, 非常头疼的问题之一就是可能存在不同的构建环境, 比如开发环境, 单元测试环境, QA环境, 部署环境等等. 最好的方案是通过传入一个参数来指定一套完整的配置环境."
category: Tech
tags: [j2ee, hibernate, maven, spring, hsqldb]
---
我在使用 maven 管理项目的时候, 非常头疼的问题之一就是可能存在不同的构建环境, 你不得不去为这些环境去做一些定制化的配置. 比如开发环境, QA环境, 生产环境中 log4j 生成的日志 level 不同, 数据库使用url, 用户名, 密码不同, 甚至可能在开发和生产环境中使用的是 MySql, 而单元测试和CI环境使用却是基于内存的 HSqlDB. 一直在考虑如果能通过添加一个配置参数来切换不同的构建方案就好了.

查看了一些资料, 看到 maven 可以通过在 pom.xml 中添加 profile 来切换配置. 下面来掩饰一下整个过程.

在 pom.xml 中添加如下代码:

{% highlight xml %}
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">

  ...

  <!-- 不同 profile 对应的构建配置 -->
  <profiles>
    <profile>
      <id>dev</id>
      <properties>
        <env>dev</env>
      </properties>
      <activation>
        <activeByDefault>true</activeByDefault>
      </activation>
    </profile>
    <profile>
      <id>product</id>
      <properties>
        <env>product</env>
      </properties>
    </profile>
    <profile>
      <id>qa</id>
      <properties>
        <env>qa</env>
      </properties>
    </profile>
    <profile>
      <id>test</id>
      <properties>
        <env>test</env>
      </properties>
    </profile>
  </profiles>

  ...

</project> 
{% endhighlight %}

可以看到, 我们定义了4个 profile: dev, product, qa, test. 分别对应到四个不同的 **env** 值, 其中通过

{% highlight xml %}
<activation>
  <activeByDefault>true</activeByDefault>
</activation>
{% endhighlight %}

来定义了 dev 为默认的 profile

我们只要在执行 maven 命令时, 通过 `-P` 来指定不同的 profile id 即可, 如:
{% highlight bash %}
$ mvn install -Pproduct
{% endhighlight %}

定义了 env, 下面通过 filter 来和 properties 文件模板来生成对应 env 的 properties 文件

我们举个例子, 在 src/main/resources/ 中添加 log4j.properties:

{% highlight properties %}
db.default.driver=${db.default.driver}

db.master.url=${db.master.url}?useUnicode=true&characterEncoding=utf8
db.master.user=${db.master.user}
db.master.password=${db.master.password}
{% endhighlight %}

这里定义和数据库相关模板配置, 接下来, 我们来写 filter 来把生成和 env 相关的配置文件.

我们在 src/main/resources/filters/ 中添加四个文件: filter-dev.properties, filter-product.properties, filter-qa.properties, filter-test.propertes, 文件的内容针对上面的模板进行配置:

{% highlight properties %}
db.default.driver=com.mysql.jdbc.Driver
db.master.url=jdbc:mysql://vipshop.db.master:3306/vipshop_passport
db.master.user=root
db.master.password=root
{% endhighlight %}

接下来, 我们继续编辑 pom.xml, 来给 maven 指定模板 resources 和 filter文件:

{% highlight xml %}
<project>

  ...

  <build>    

    ...

    <filters>
      <filter>src/main/resources/filters/filter-${env}.properties</filter>
    </filters>
    <resources>
      <resource>
        <directory>src/main/resources</directory>
        <filtering>true</filtering>
      </resource>
    </resources>

    ...
    
  </build>

  ...

</project>
{% endhighlight %}

ok, 基本的配置完成了. 我们测试一下:

{% highlight bash %}
$ mvn process-sources -Pproduct
{% endhighlight %}

看看在 /target/classes/ 中有没有生成 db.properties, 并且已经根据指定的 env 配置好了参数?
