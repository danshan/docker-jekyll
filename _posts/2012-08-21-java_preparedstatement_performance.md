---
layout: post
title: 测试PreparedStatement的批处理效率
date: 2012-08-21 15:05
description: "今天研究了一下Java中**PreparedStatement**的批处理能力.<br/>
测试环境如下:<br/>
jdk1.6.0_21 + Mysql 5.1<br/>
Core 2 Duo T5470 (1.60GHz) + 3G内存<br/>
测试的是实现最简单的插入."
category: Tech
tags: [mysql, java]
---

今天研究了一下Java中**PreparedStatement**的批处理能力.
测试环境如下:

    jdk1.6.0_21 +Mysql 5.1
    Core 2 Duo T5470 (1.60GHz) + 3G内存

测试的是实现最简单的插入:

{% highlight sql %}
INSERT INTO `testdb` (`id`, `value`) VALUES (123456, 'http://www.pptv.com');
{% endhighlight %}

共插入20万条数据, 每个测试前都把数据库清空, 然后执行插入, 从开始插入进行计时.每项测试跑3次取平均值.

分为两项测试: 1个是不使用批处理, 逐条插入; 一个是使用`addBatch()`, 分别按50, 100, 500, 1000, 5000, 10000, 50000, 100000的划分方式进行批量插入. 关键代码如下:

逐行插入:
{% highlight java %}
for (int times = 0; times < TEST_TIMES; times++) {
    cleanDB();
    conn = DBMgr.getDBconn("testdb");
    long starttime = System.currentTimeMillis();
    for (int i = 0; i < MAX_COUNT; i++) {
         pstmt = conn.prepareStatement(SQL);
         pstmt.executeUpdate();
         pstmt.close();
         System.out.println("working: " + i + "/" + MAX_COUNT);
    }
    long endtime = System.currentTimeMillis();
    logger.info("第" + (times + 1) + "次测试, 耗时" + (endtime - starttime) + "ms");
    alltime += endtime - starttime;
}
logger.info("平均耗时: " + (alltime / TEST_TIMES) + "ms");
{% endhighlight %}

批处理操作

{% highlight java %}
for (int times = 0; times < TEST_TIMES; times++) {
    cleanDB();
    conn = DBMgr.getDBconn("testdb");
    conn.setAutoCommit(false);
    int num = 0;
    long starttime = System.currentTimeMillis();
    pstmt = conn.prepareStatement(SQL);
    for (int i = 0; i < MAX_COUNT; i++) {
        pstmt.addBatch();
        num++;
        if (num % count == 0 || num == MAX_COUNT) {
            pstmt.executeBatch();
            pstmt.clearBatch();
            pstmt.close();
            pstmt = conn.prepareStatement(SQL);
        }
        System.out.println("working: " + i + "/" + MAX_COUNT);
    }
    long endtime = System.currentTimeMillis();
    logger.info("第" + (times + 1) + "次测试, 耗时" + (endtime - starttime) + "ms");
    alltime += endtime - starttime;
}
logger.info("平均耗时: " + (alltime / TEST_TIMES) + "ms");
{% endhighlight %}

记录的log如下:

    11:59:25,703 DBTestMulti test  *** 以100000为一次批量操作, 执行批处理语句  ***
    11:59:25,703 BaseDBTest cleanDB 初始化数据库
    11:59:58,984 DBTestMulti test 第1次测试, 耗时33000ms
    11:59:58,984 BaseDBTest cleanDB 初始化数据库
    12:01:21,687 DBTestMulti test 第2次测试, 耗时32594ms
    12:01:21,687 BaseDBTest cleanDB 初始化数据库
    12:02:44,640 DBTestMulti test 第3次测试, 耗时32562ms
    12:02:44,640 DBTestMulti test 平均耗时: 32718ms
    12:02:47,093 DBTestMulti test  *** 以50000为一次批量操作, 执行批处理语句  ***
    12:02:47,093 BaseDBTest cleanDB 初始化数据库
    12:03:19,734 DBTestMulti test 第1次测试, 耗时32625ms
    12:03:19,734 BaseDBTest cleanDB 初始化数据库
    12:04:43,406 DBTestMulti test 第2次测试, 耗时33328ms
    12:04:43,406 BaseDBTest cleanDB 初始化数据库
    12:06:06,687 DBTestMulti test 第3次测试, 耗时32609ms
    12:06:06,687 DBTestMulti test 平均耗时: 32854ms
    12:06:09,125 DBTestMulti test  *** 以10000为一次批量操作, 执行批处理语句  ***
    12:06:09,125 BaseDBTest cleanDB 初始化数据库
    12:06:40,921 DBTestMulti test 第1次测试, 耗时31781ms
    12:06:40,921 BaseDBTest cleanDB 初始化数据库
    12:08:03,125 DBTestMulti test 第2次测试, 耗时32032ms
    12:08:03,125 BaseDBTest cleanDB 初始化数据库
    12:09:26,859 DBTestMulti test 第3次测试, 耗时32781ms
    12:09:26,859 DBTestMulti test 平均耗时: 32198ms
    12:09:29,296 DBTestMulti test  *** 以5000为一次批量操作, 执行批处理语句  ***
    12:09:29,296 BaseDBTest cleanDB 初始化数据库
    12:10:00,406 DBTestMulti test 第1次测试, 耗时31094ms
    12:10:00,406 BaseDBTest cleanDB 初始化数据库
    12:11:23,031 DBTestMulti test 第2次测试, 耗时31953ms
    12:11:23,031 BaseDBTest cleanDB 初始化数据库
    12:12:46,265 DBTestMulti test 第3次测试, 耗时32187ms
    12:12:46,265 DBTestMulti test 平均耗时: 31744ms
    12:12:48,718 DBTestMulti test  *** 以1000为一次批量操作, 执行批处理语句  ***
    12:12:48,718 BaseDBTest cleanDB 初始化数据库
    12:13:20,468 DBTestMulti test 第1次测试, 耗时31750ms
    12:13:20,468 BaseDBTest cleanDB 初始化数据库
    12:14:43,703 DBTestMulti test 第2次测试, 耗时32625ms
    12:14:43,703 BaseDBTest cleanDB 初始化数据库
    12:16:06,203 DBTestMulti test 第3次测试, 耗时32125ms
    12:16:06,203 DBTestMulti test 平均耗时: 32166ms
    12:16:08,656 DBTestMulti test  *** 以500为一次批量操作, 执行批处理语句  ***
    12:16:08,656 BaseDBTest cleanDB 初始化数据库
    12:16:40,906 DBTestMulti test 第1次测试, 耗时32235ms
    12:16:40,906 BaseDBTest cleanDB 初始化数据库
    12:18:03,625 DBTestMulti test 第2次测试, 耗时32547ms
    12:18:03,625 BaseDBTest cleanDB 初始化数据库
    12:19:27,343 DBTestMulti test 第3次测试, 耗时33265ms
    12:19:27,343 DBTestMulti test 平均耗时: 32682ms
    12:19:30,406 DBTestMulti test  *** 以100为一次批量操作, 执行批处理语句  ***
    12:19:30,406 BaseDBTest cleanDB 初始化数据库
    12:20:53,875 DBTestMulti test 第1次测试, 耗时32782ms
    12:20:53,875 BaseDBTest cleanDB 初始化数据库
    12:22:17,765 DBTestMulti test 第2次测试, 耗时33687ms
    12:22:17,765 BaseDBTest cleanDB 初始化数据库
    12:23:41,609 DBTestMulti test 第3次测试, 耗时33531ms
    12:23:41,609 DBTestMulti test 平均耗时: 33333ms
    12:23:44,421 DBTestMulti test  *** 以50为一次批量操作, 执行批处理语句  ***
    12:23:44,421 BaseDBTest cleanDB 初始化数据库
    12:25:07,578 DBTestMulti test 第1次测试, 耗时32500ms
    12:25:07,578 BaseDBTest cleanDB 初始化数据库
    12:26:31,796 DBTestMulti test 第2次测试, 耗时33718ms
    12:26:31,796 BaseDBTest cleanDB 初始化数据库
    12:27:55,640 DBTestMulti test 第3次测试, 耗时33562ms
    12:27:55,640 DBTestMulti test 平均耗时: 33260ms
    12:27:58,468 BaseDBTest cleanDB 初始化数据库
    14:08:25,484 DBTestSingle test 第1次测试, 耗时5976406ms
    14:08:25,484 BaseDBTest cleanDB 初始化数据库
    15:47:18,828 DBTestSingle test 第2次测试, 耗时5882735ms
    15:47:18,828 BaseDBTest cleanDB 初始化数据库

其中批处理都是执行3次取平均值, 而逐行操作, 一次执行时间就要1个半小时, 所以只跑了两次. 日志筛选如下:

    每次100000条, 分2次处理: 32718ms
    每次50000条, 分4次处理: 32854ms
    每次10000条, 分20次处理: 32198ms
    每次5000条, 分40次处理: 31744ms
    每次1000条, 分200次处理: 32166ms
    每次500条, 分400次处理: 32682ms
    每次100条, 分2000次处理: 33333ms
    每次50条, 分4000次处理: 33260ms

而最后的两条是没有使用批处理跑出来的 用时近600000ms, 近1小时40分钟, 完全不是一个数量级的.

相比较而言, 批处理语句在量的划分上差别并不明显, 在千级的划分只有一点点的减少.

