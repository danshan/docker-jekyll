---
layout: post
title: Hibernate 配置写入数据库时自动设置系统时间
date: 2013-01-06 11:27
description: "通过配置 hbm.xml 文件使 hibernate 写入数据库时自动生成写入时的系统时间, 用于需要记录注册时间的场合, 如'用户注册时间'等"
category: Tech
tags: [j2ee, hibernate]
---
如果类的一个特定属性有着数据库生成的值, 通常在第一次插入实体行的时候. 典型的数据库生成的值是创建的时间戳, 还有其它默认值等.

使用 property 映射中的 **generated** 开关启用这个自动刷新:

{% highlight xml %}
<?xml version="1.0"?>
<!DOCTYPE hibernate-mapping PUBLIC "-//Hibernate/Hibernate Mapping DTD 3.0//EN"
"http://hibernate.sourceforge.net/hibernate-mapping-3.0.dtd">
<!-- Generated Jan 5, 2013 2:10:24 PM by Hibernate Tools 3.4.0.CR1 -->
<hibernate-mapping>
    <class name="com.vipshop.cmprice.vo.ItemInfo" table="item_info">
        <id name="id" type="int">
            <column name="id" />
            <generator class="increment" />
        </id>
        <property name="sku" type="java.lang.String">
            <column name="sku" />
        </property>
        <property name="platform" type="java.lang.String">
            <column name="platform" />
        </property>
        <property name="itemTitle" type="java.lang.String">
            <column name="item_title" />
        </property>
        <property name="itemPrice" type="java.lang.String">
            <column name="item_price" />
        </property>
        <property name="itemLink" type="java.lang.String">
            <column name="item_link" />
        </property>
        <property name="storeLink" type="java.lang.String">
            <column name="store_link" />
        </property>
        <property name="storeTitle" type="java.lang.String">
            <column name="store_title" />
        </property>
        <property name="itemImage" type="java.lang.String">
            <column name="item_image" />
        </property>
        <property name="createTime" type="java.util.Date" generated="insert" not-null="true">
            <column name="create_time" sql-type="timestamp" default="CURRENT_TIMESTAMP" />
        </property>
    </class>
</hibernate-mapping>
{% endhighlight %}

其中, 最下面**createTime**的配置:

{% highlight xml %}
<property name="createTime" type="java.util.Date" generated="insert" not-null="true">
    <column name="create_time" sql-type="timestamp" default="CURRENT_TIMESTAMP" />
</property>
{% endhighlight %}

关于 **generated** 的适用值说明:

* **never(默认)**: 标明此属性值不是从数据库中生成, 也就是根本不用刷新实体类了.
* **insert**: 标明此属性值在insert的时候生成, 但是不会在随后的update时重新生成. 也就是只在insert情况下才会刷新实体类.
* **always**: 标明此属性值在insert和update时都会被生成, 也就是在insert, update情况下都会刷新实体类.

**sql-type** 指生成的时间的类型

**default** Hibernate本身提供 _current\_date_, _current\_timestamp_ 和 _current\_time_ 三种函数.
