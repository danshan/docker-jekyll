---
layout: post
title: proxool 0.8.3使用java搭建MySql连接池的配置和测试
date: 2012-11-27 15:00
description: "在企业开发的时候, 很多情况都会使用数据库连接, 下文将介绍proxool连接池的使用和配置以及测试方案."
category: Tech
tags: [java, proxool, database, j2ee]
---

在企业开发的时候, 很多情况都会使用数据库连接, 下文将介绍proxool连接池的使用和配置以及测试方案.

下载 [proxool 0.8.3](http://proxool.sourceforge.net/)

创建一个xml配置文件db.xml, 放在CLASSPATH路径:

{% highlight xml %}
<xml version="1.0" encoding="UTF-8">
<something-else-entirely>
  <proxool>
    <!-- 数据源的别名 -->
    <alias>search</alias>
    <driver-url>jdbc:mysql://localhost:3306/search</driver-url>
    <driver-class>com.mysql.jdbc.Driver</driver-class>

    <!-- 连接池使用状况统计 -->
    <statistics>1m,15m,1d</statistics>
    <driver-properties>
      <property name="user" value="root" />
      <property name="password" value="root"/>
      <property name="characterEncoding" value="UTF-8"/>
      <property name="useUnicode" value="true"/>
    </driver-properties>

    <!--
    proxool自动侦察各个连接状态的时间间隔(毫秒)
    侦察到空闲的连接就马上回收,超时的销毁 默认30秒
    -->
    <house-keeping-sleep-time>90000</house-keeping-sleep-time>
    
    <!--
    连接池中可用的连接数量.
    如果当前的连接池中的连接少于这个数值. 新的连接将被建立(假设没有超过最大可用数).
    例如.我们有3个活动连接2个可用连接, 而我们的prototype-count是4, 那么数据库连接池将
    试图建立另外2个连接. 这和 minimum-connection-count 不同. minimum-connection-count
    把活动的连接也计算在内.
    prototype-count 是spare connections 的数量.
    -->
    <prototype-count>5</prototype-count>

    <!--
    最大连接数(默认5个),超过了这个连接数,再有请求时,就排在队列中等候, 最大的等待
    请求数由maximum-new-connections决定
    -->
    <maximum-connection-count>100</maximum-connection-count>
    <simultaneous-build-throttle>100</simultaneous-build-throttle>
    <!--最小连接数(默认2个) -->
    <minimum-connection-count>2</minimum-connection-count>
    
    <!--
    如果housekeeper 检测到某个线程的活动时间大于这个数值.它将会杀掉这线程
    所以确认一下你的服务器的带宽.然后定一个合适的值.默认是5分钟
    -->
    <maximum-active-time>300000</maximum-active-time>
    <house-keeping-test-sql>select CURRENT_DATE</house-keeping-test-sql>
  </proxool>
</something-else-entirely>
{% endhighlight %}

如果有多个数据库, 则要使用多个proxool标签, 配置不同的alias.

然后配置web.xml, 里见加入:

{% highlight xml %}
<servlet>
  <description>proxool配置servlet</description>
  <servlet-name>ServletConfigurator</servlet-name>
  <servlet-class>org.logicalcobwebs.proxool.configuration.ServletConfigurator</servlet-class>
  <init-param>
    <param-name>xmlFile</param-name>
    <!-- 这里是上面那个配置文件的路径 -->
    <param-value>WEB-INF/classes/db.xml</param-value>
  </init-param>
  <load-on-startup>1</load-on-startup>
</servlet>
<servlet>
  <description>proxool管理servlet</description>
  <servlet-name>proxool</servlet-name>
  <servlet-class>org.logicalcobwebs.proxool.admin.servlet.AdminServlet</servlet-class>
</servlet>
<servlet-mapping>
  <servlet-name>proxool</servlet-name>
  <url-pattern>/admin</url-pattern>
</servlet-mapping>
{% endhighlight %}

创建一个DBMgr.java, 作为连接数据库的模板类:

{% highlight java %}
package com.pptv.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import org.apache.log4j.Logger;

/**
 * 数据库的基本连接类, 通过proxool连接池连接Mysql
 *
 * @author Dan Shan
 *
 */
public final class DBMgr {

    private static final Logger Logger = Logger.getLogger(DBMgr.class);
    
    static {
        try {
            Class.forName("org.logicalcobwebs.proxool.ProxoolDriver");
        } catch (ClassNotFoundException e) {
            logger.error("Load proxool failed", e);
        }
    }

    /**
     * 所有方法都为static, 不允许实例化.
     */
    private DBMgr() {
    }

    public static Connection getDBconn(final String dbName) throws SQLException {
        Connection conn = null;
        try {
            conn = DriverManager.getConnection("proxool." + dbName);
        } catch (Exception e) {
            logger.error("Read the database configuration files error", e);
        }
        return conn;
    }
}
{% endhighlight %}
    
至于怎么用, 都应该知道了, 调用getDBconn时, 传入最上面db.xml中设定的alias值, 即可连接不同的数据库.

再来说测试, 使用单元测试的时候, 并不希望每次都启动网站来测试, 希望直接就能调用数据库的配置. 其实也很简单: 

{% highlight java %}
package com.pptv.config;

import java.sql.Connection;
import java.sql.SQLException;
import junit.framework.TestCase;
import org.junit.Test;
import org.logicalcobwebs.proxool.ProxoolException;
import org.logicalcobwebs.proxool.ProxoolFacade;
import org.logicalcobwebs.proxool.configuration.JAXPConfigurator;

public class DBMgrTest extends TestCase {
    private Connection conn;

    @Override
    protected void setUp() throws Exception {
        super.setUp();
        String dbConfigFile = DBMgrTest.class.getResource("/db.xml").getPath();
        try {
            JAXPConfigurator.configure(dbConfigFile, false);
        } catch (ProxoolException e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void tearDown() throws Exception {
        super.tearDown();
        if (conn != null) {
            conn.close();
        }
        ProxoolFacade.shutdown(0);
    }
    
    @Test
    public void testGetDBconn() throws SQLException {
        conn = DBMgr.getDBconn("search");
        assertNotNull(conn);
    }
}
{% endhighlight %}
    
只要手动加载配置文件, 见setUp()方法.
这里注意一下, 单元测试需要手动的关闭连接池, 否则测试程序停止后会抛异常, 见`tearDown()`方法的最后一行: 

{% highlight java %}
ProxoolFacade.shutdown(0);
{% endhighlight %}

连接池个别情况不能替代传统的jdbc连接, 比如需要建立长连接时, 这个时候, 可能就需要创建一个保持连接的Connection, 而不能使用proxool了, 因为会被自动Kill.

