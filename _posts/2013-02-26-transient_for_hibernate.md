---
layout: post
title: 过滤 hibernate 映射中的某些指定属性
date: 2013-02-26 18:27
description: "有时候处理一些特殊的 hibernate 映射关系, 需要对某些映射的 VO 对象中过滤一些数据库中并不存在的属性."
category: Tech
tags: [hibernate]
---
在公司处理一个 php 的项目, 要用 java 重新实现底层的逻辑功能. 碰到这样一个很蛋疼的情况:

以前的数据库设计非常混乱, User表中, 关于注册时间有如下两个字段, 表示重复的功能:

    reg_date int(8) 示例”20130101”
    add_time char(8) 示例”2013-01-01 23:59:59”

同样在user表中, 存在着各种奇怪的时间格式

    birthday char(10) 示例”20130101”
    web_time char(20)
    congeal_time char(10)
    last_time char(20)
    stat_time char(20)
    order_consume_time int(11)
    final_mail_time int(11)
    subscribe_time int(10)
 
更奇怪的是, 同样是add_time, 表示添加时间, 在不同的表里有完全不同的时间格式, 长度也不同:

User表:

    add_time char(20) 示例”2013-01-01 23:59:59”
     
mark_record表:

    add_time int(11), 1970-01-01至今的秒数
 
user_size表:

    create_time int(10), 1970-01-01至今的秒数

看到这种数据库, 直接崩溃了. 没办法, 历史遗留问题, 一定要处理的, 我这里的解决方案是, 在 hibernate 的映射 VO 定义中, 对一些恶心的字段进行封装

{% highlight java %}
@Entity
@org.hibernate.annotations.Entity(dynamicInsert = true, dynamicUpdate = true)
@Table(name="user")
public class User {

    /** 
     * 真正的注册时间.
     * 修改这个时间的set方法, 给另两个时间进行赋值
     */
    @Transient
    private Date createTime = null;
    
    /** 另一个欠干的创建时间 yyyy-MM-dd HH-mm-ss*/
    @Column(name="add_time", length=20, nullable=true, updatable=false)
    private String createTimeFuckString = null;
    
    /**
     * 另一个前干的创建时间创建时间 yyyyMMdd, 不知道有个P用, 
     * 原有的数据库里保存了两个用于描述注册时间的不同格式字段, 不敢删, 只能原样保留.
     * 同样崩溃的地方还有: birthday的格式为String的yyyyMMdd
     */
    @Column(name="reg_date", length=8, nullable=true)
    private Integer createTimeFuckInt = null;
    
    public User() {
        super();
    }

    /** @return the createTime */
    public Date getCreateTime() {
        return createTime;
    }
    
    /** @param createTime the createTime to set */
    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
        if (createTime == null) {
            this.createTimeFuckString = null;
            this.createTimeFuckInt = null;
        } else {
            String createTimeStr = SuperDate.formatDateTime(createTime, "yyyyMMdd");
            this.createTimeFuckInt = Integer.parseInt(createTimeStr);
            this.createTimeFuckString = new SuperDate(createTime).getDateTimeString();
        }
    }

    /** @return the createTimeFuckString */
    public String getCreateTimeFuckString() {
        return createTimeFuckString;
    }

    /** @param createTimeFuckString the createTimeFuck to set */
    private void setCreateTimeFuckString(String createTimeFuckString) {
        this.createTimeFuckString = createTimeFuckString;
        if (createTimeFuckString == null) {
            this.createTime = null;
            this.createTimeFuckString = null;
        } else {
            SuperDate date = new SuperDate(createTimeFuckString);
            this.createTime = date.getDate();
            this.createTimeFuckInt = Integer.parseInt(
                    SuperDate.formatDateTime(this.createTime, "yyyyMMdd"));
        }
    }

    /** @return the createTimeFuckInt */
    public Integer getCreateTimeFuckInt() {
        return createTimeFuckInt;
    }

    /** @param createTimeFuckInt the createTimeFuckInt to set */
    private void setCreateTimeFuckInt(Integer createTimeFuckInt) {
        this.createTimeFuckInt = createTimeFuckInt;
        if (createTimeFuckInt == null) {
            this.createTime = null;
            this.createTimeFuckString = null;
        } else {
            String createTimeFuckIntStr = String.valueOf(createTimeFuckInt);
            if (createTimeFuckIntStr.length() != 8) {
                return;
            }
            
            SuperDate date = new SuperDate(
                    createTimeFuckIntStr.substring(0, 4),
                    createTimeFuckIntStr.substring(4, 6),
                    createTimeFuckIntStr.substring(6));
            this.createTime = date.getDate();
            this.createTimeFuckString = date.getDateTimeString();
        }
    }
}
{% endhighlight %}

代码只列出关于时间的操作. 创建一个 Date 类型的 createTime, 作为唯一的 public set 操作. createTimeFuckInt, createTimeFuckString 这两个字段分别对应着映射到数据库的列, 但将 set 方法设置为 private的.

这里注意一个细节, 在定义 createTime 时, 要添加 **@Transient**, 来申明这个树形在数据库中不做映射操作.

{% highlight java %}
    /** 
     * 真正的注册时间.
     * 修改这个时间的set方法, 给另两个时间进行赋值
     */
    @Transient
    private Date createTime = null;
{% endhighlight %}
