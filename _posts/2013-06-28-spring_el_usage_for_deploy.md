---
layout: post
title: 通过 spring 的 EL 表达式解决不同环境的部署参数配置问题
date: 2013-06-28 16:20
description: "在我们一个真实项目中, 用到了 QA/DEV/TEST/PRODUCT 四套部署环境. 前三套类似, 只是在 PRODUCT 环境中, 公司的运维规范是将配置信息写到 linux 系统的环境变量中, 而这个配置信息的值是不能公开给我们的开发人员的. 这就需要我们在项目的部署问题上支持多种环境的配置方式."
category: Tech
tags: [spring, el]
---
在我们一个真实项目中, 用到了 QA/DEV/TEST/PRODUCT 四套部署环境. 前三套类似, 只是在 PRODUCT 环境中, 公司的运维规范是将配置信息写到 linux 系统的环境变量中, 而这个配置信息的值是不能公开给我们的开发人员的. 这就需要我们在项目的部署问题上支持多种环境的配置方式.

我们需要满足下面几点需求:

1. 交付给运维人员的是一个直接可以部署的 war 包. 运维只根据约定的参数直接修改系统的环境变量即可完成部署工作.
1. 对于 QA 和开发人员, 同样是交付给他们一个可部署的 war 包, 而这个 war 中的配置信息是写在配置文件中. 不需配置环境变量.
1. 对于不同环境的打包, 不应有任何代码的修改, 直接通过一个参数打成对应不同环境的 war.
1. 运维今后可能会有对系统环境变量中的值作加密的需求, 也就是说, 这套部署逻辑应当支持对取值的算法定制.

通过我的前面的一篇文章, 介绍了如何通过 maven 将项目根据不同环境要求进行打包. 参考[Maven 根据不同的 profile 对不同的构建环境进行配置](/blog/2013/01/25/maven_package_with_profile_id/).

下面我们在基于那篇文章作进一步的修改, 以满足我们新增的需求.

首先来聊聊 Spring 的 EL 表达式 [SpEL](http://static.springsource.org/spring/docs/3.0.x/reference/expressions.html)

>6.4 Expression support for defining bean definitions
>
> SpEL expressions can be used with XML or annotation based configuration metadata for defining BeanDefinitions. In both cases the syntax to define the expression is of the form #{ &lt;expression string&gt; }.
>
>6.4.1 XML based configuration
>
> A property or constructor-arg value can be set using expressions as shown below

{% highlight xml %}
<bean id="numberGuess" class="org.spring.samples.NumberGuess">
  <property name="randomNumber" value="#{ T(java.lang.Math).random() * 100.0 }"/>
</bean>
{% endhighlight %}

>The variable 'systemProperties' is predefined, so you can use it in your expressions as shown below. Note that you do not have to prefix the predefined variable with the '#' symbol in this context.

{% highlight xml %}
<bean id="taxCalculator" class="org.spring.samples.TaxCalculator">
  <property name="defaultLocale" value="#{ systemProperties['user.region'] }"/>
</bean>
{% endhighlight %}

>You can also refer to other bean properties by name, for example.

{% highlight xml %}
<bean id="numberGuess" class="org.spring.samples.NumberGuess">
  <property name="randomNumber" value="#{ T(java.lang.Math).random() * 100.0 }"/>
</bean>

<bean id="shapeGuess" class="org.spring.samples.ShapeGuess">
  <property name="initialShapeSeed" value="#{ numberGuess.randomNumber }"/>
</bean>
{% endhighlight %}

通过这几个例子, 我们知道了 EL 中不但可以直接使用参数, 还可以直接调用 java 的方法.
我们下面就开始利用这些特性来解决前面的问题.

已数据库配置为例, 我们需要创建一个 Class, 用于读取系统环境变量:

{% highlight java %}
package com.vipshop.passport.core.common;

/**
 * 读取系统环境变量
 * @author dan.shan
 * @since 2013-5-30 18:34:02
 */
public class SystemUtil {
    
    /**
     * 读取系统变量
     * @author dan.shan
     * @since 2013-5-30 18:34:08 
     **/
    private static String getSystemValue(String key){
        return System.getenv(key);
    }
    
    public static String getDBUrl(){
        String host = getSystemValue("VIP_DB_HOST");
        String database = getSystemValue("VIP_DB_DATABASE");
        if(SuperString.isBlank(host) || SuperString.isBlank(database)){
            return null;
        }
        
        return "jdbc:mysql://" + host + "/" + database + "?useUnicode=true&amp;characterEncoding=utf8";
    }
    
    public static String getUserName(){
        String userName = getSystemValue("VIP_DB_USERNAME");
        return SuperString.isBlank(userName) ? null : userName;
    }
    
    public static String getPassword(){
        String password = getSystemValue("VIP_DB_PASSWORD");
        return SuperString.isBlank(password) ? null : password;
    }
    
}
{% endhighlight %}

java 中定义了 `getDBUrl()`, `getUserName()`, `getPassword()` 来获取数据库链接信息. 我们在 spring 中对 datasource 的配置稍作修改:

{% highlight xml %}
<!-- MySQL -->
<bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource" destroy-method="close"> 
    <property name="driverClass" value="${db.driver}" />
    <property name="jdbcUrl" value="#{'${db.url}' == '' ? T(com.vipshop.passport.core.common.SystemUtil).getDBUrl() : '${db.url}'}" />
    <property name="user" value="#{'${db.user}' == '' ? T(com.vipshop.passport.core.common.SystemUtil).getUserName() : '${db.user}'}" />
    <property name="password" value="#{'${db.password}' == '' ? T(com.vipshop.passport.core.common.SystemUtil).getPassword() : '${db.password}'}" />
    <!-- 省略c3p0配置 -->
</bean>
{% endhighlight %}

可以看到, xml 中尝试了去读取 `${db.driver}`, `${db.url}`, `${db.user}`, `${db.password}`. 当这些参数不为空的时候, 就会调用刚刚我们定义的 class 的方法取获取环境变量.
而至于这四个变量从哪里来的, 可以参考文首提到的那篇关于 maven filter 的文章.

下面我们针对不同的环境, 来写不同的 filter:
{% highlight bash %}
# filter-product.properties
db.default.driver=com.mysql.jdbc.Driver
db.url=
db.user=
db.password=

# filter-dev.properties
db.default.driver=com.mysql.jdbc.Driver
db.url=jdbc:mysql://vipshop.db.master:3306/passport?useUnicode=true&amp;characterEncoding=utf8
db.user=passport
db.password=passport
{% endhighlight %}

可见, 我们将生产环境的配置项全部留空, 这样打包的时候 maven, 会根据配置文件的内容, 将空字符串写到spring的配置文件中: 

{% highlight xml %}
<bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource" destroy-method="close"> 
    <property name="jdbcUrl" value="#{'' == '' ? T(com.vipshop.passport.core.common.SystemUtil).getFDSDBUrl() : ''" />
</bean>
{% endhighlight %}

这样就会 spring 就会从系统环境变量去加载配置信息.
