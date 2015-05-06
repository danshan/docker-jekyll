---
layout: post
title: 在 Spring 托管的项目中引入 h2 database 作单元测试
date: 2013-08-24 16:20
description: "为了让单元测试尽可能的脱离开发环境种种依赖, 最好的办法是在单元测试的时候引入内存数据库."
category: Tech
tags: [spring, testng, h2]
---
为了让单元测试尽可能的脱离开发环境种种依赖, 最好的办法是在单元测试的时候引入内存数据库.

之前我们也曾使用过 [hsqldb](http://hsqldb.org/) 来做单元测试, 但是在刚开始的时候, 还能满足简单的测试需求; 
随着数据库结构和查询条件越来越复杂, 发现 hsqldb 的弊端体现的越来越明显, 最终不得不放弃它.

hsqldb 在使用中碰到的最大的几个问题是, 与 mysql 数据库的 sql 存在较大差异, 尤其体现在 **自增ID** 和 **LIMIT** 的使用上.
使得我们为了单元测试而不得不去维护两套不同的 sql. 成本非常大, 也丧失了单元测试的优点.

直到我们引用了 [h2](http://h2database.com/html/main.html):

相比 hsqldb 而言, h2 带来的最大改善, 就是几乎完全兼容以前 mysql sql, DDL 直接就能正常执行, 简直太方便了.

下面说一下简单的配置, 以方便大家作参考.

maven 配置文件 pom.xml 中引入相关的 dependency:

{% highlight xml %}
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <version>1.3.173</version>
</dependency>
<dependency>
    <groupId>org.testng</groupId>
    <artifactId>testng</artifactId>
    <version>6.8.5</version>
</dependency>
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-test</artifactId>
    <version>3.0.5.RELEASE</version>
</dependency>
{% endhighlight %}

下面为单元测试指定 datasource.
个人经验是, 为了方便开发环境和单元测试环境使用不同的 datasource, 我们将 spring 中关于 datasource 的配置单独放在一个文件中.
这样的好处是, 在 `src/main/resources/` 和 `src/test/resources/` 下各有一个同名的 datasource 配置文件, 而在执行 test 时, 会自动用 test resources 中的配置文件替换 main中的配置.

_applicationContext-datasource.xml_

{% highlight xml %}
<?xml version="1.0" encoding="UTF-8"?>

<beans xmlns="http://www.springframework.org/schema/beans"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:jdbc="http://www.springframework.org/schema/jdbc"
        xsi:schemaLocation="http://www.springframework.org/schema/beans
                http://www.springframework.org/schema/beans/spring-beans-3.0.xsd
                http://www.springframework.org/schema/jdbc
                http://www.springframework.org/schema/jdbc/spring-jdbc.xsd">

  <jdbc:embedded-database id="dataSource" type="H2">
    <jdbc:script location="classpath:database/h2_schema.sql"/>
    <jdbc:script location="classpath:database/h2_test_data.sql"/>
  </jdbc:embedded-database>

</beans>
{% endhighlight %}

这里看到我们导入了两个 sql 文件, 分别用来创建表结构和导入测试数据. 基本的 sql 语法就不说, 记得在 sql 的第一行 标注 `SET MODE MYSQL;` 用来表示兼容 mysql 语义:

{% highlight sql %}
SET MODE MYSQL;

-- --------------------------------------------------------

--
-- Table structure for table us_app
--

CREATE TABLE IF NOT EXISTS us_app (
  id int(11) NOT NULL AUTO_INCREMENT,
  title varchar(31) NOT NULL,
  username varchar(255) NOT NULL,
  password varchar(255) NOT NULL,
  grant_id int(11) NOT NULL,
  create_user varchar(30) NOT NULL,
  update_user varchar(30) NOT NULL,
  create_time datetime NOT NULL,
  update_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
);
{% endhighlight %}

之后在 applicationContext.xml import 这个文件:

_applicationContext.xml_

{% highlight xml %}
<?xml version="1.0" encoding="UTF-8"?>

<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
                http://www.springframework.org/schema/beans/spring-beans-3.0.xsd
                http://www.springframework.org/schema/context
                http://www.springframework.org/schema/context/spring-context-3.0.xsd">

    <context:property-placeholder location="classpath:service.db.properties, classpath:service.properties"/>

    <import resource="applicationContext-service.xml"/>
    <import resource="applicationContext-datasource.xml"/>
    <import resource="applicationContext-mybatis.xml"/>

    <!-- 指明需要进行annotation扫描的包 -->
    <context:component-scan base-package="com.vipshop.auth"/>

</beans>
{% endhighlight %}

之后的操作就没什么好说了, 最好创建一个单元测试的 BASE 类, 用来继承 TestNG 和加载 Spring 配置文件:

{% highlight java %}
/**
 * @author: dan.shan
 * @since: 2013-08-14 22:47
 */
@ContextConfiguration(locations = { "classpath:/spring/applicationContext.xml" })
public abstract class SpringContextTestParent extends AbstractTestNGSpringContextTests {

}
{% endhighlight %}

而真正的单元测试 class 继承该类:

{% highlight java %}
/**
 * @author: dan.shan
 * @since: 2013-08-14 22:52
 */
public class ProfileRecoDaoTest extends SpringContextTestParent {

    @Autowired
    private ProfileRecoDao profileRecoDao;

    @Test
    public void testFindOne() {
        int userId = 1;
        ProfileReco result = profileRecoDao.findOne(userId);

        assertEquals("A", result.getType());
    }

    @Test
    public void testFindOneNotExsit() {
        ProfileReco result = profileRecoDao.findOne(Integer.MAX_VALUE);
        assertNull(result);
    }
}
{% endhighlight %}

后面不用说了, 执行就是了.
