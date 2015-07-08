---
layout: page
title: "Dan's Resume"
image:
  feature: abstract-5.jpg
  credit: dargadgetz
  creditlink: http://www.dargadgetz.com/ios-7-abstract-wallpaper-pack-for-iphone-5-and-ipod-touch-retina/
date: 2015-05-28
comments: false
--- 

# [单弘昊](http://www.shanhh.com)

> 男 | 1986年10月 | 户口: 上海

> Mobile: 18616354707 | E-mail: [i@shanhh.com](mailto://i@shanhh.com)

---

**教育经历**

2006/09 –2010/07: [华中科技大学](http://www.hust.edu.cn/) | 软件工程 | 本科

---

## 工作经验

### 2014/05 – 至今: [大众点评](http://www.dianping.com) Java高级开发工程师

来点评刚满一年, 由于之前一直从事互联网开发工作, 所以入手这边的工作非常快, 也可以说是得心应手. 但是缺点也在于这里: 有点太得心应手了, 反而缺少了挑战性. 由于所在的结婚事业部过于贴近业务, 缺少自主研发的技术上的积累, 常常被一些琐碎的需求束手束脚.

**开发工具:** Spring, Struts, SpringMVC, iBatis, Redis, [Drools](http://www.drools.org/), Freemarker, MongoDB

**责任描述:** 所有和结婚/亲子相关的页面, 都参与了开发. 包括 [网站](http://www.dianping.com), [M站](http://m.dianping.com), [商户后台](http://e.dianping.com), 运营后台, 甚至是ios客户端.

**项目描述:** 做的事情比较杂, 因为几乎所有的和结婚/亲子相关的东西都参与了. 这里只简单说一下一些贡献:

1. 刚入公司, 读代码发现了几处sql注入漏洞, 修改了商户后台很多 [xss漏洞](https://zh.wikipedia.org/wiki/%E8%B7%A8%E7%B6%B2%E7%AB%99%E6%8C%87%E4%BB%A4%E7%A2%BC) 和 [csrf漏洞](https://zh.wikipedia.org/wiki/%E8%B7%A8%E7%AB%99%E8%AF%B7%E6%B1%82%E4%BC%AA%E9%80%A0). 因为之前在唯品会做用户中心, 对代码安全性比较敏感. 常常帮助review新上线的项目代码和一些涉及敏感数据的业务逻辑.

2. 之前点评NoSql基本用的都是memcache和mongodb, 根据业务需要, 在部门中推广使用redis, 满足一些特殊的需求, 比如之前做过的晒客照的排行榜.

3. 由于客户端的经济化运营, 在给app的接口服务中引入 [drools](http://www.drools.org/) 规则引擎, 把复杂的业务逻辑从代码中抽离. 方便统一管理和变更.

4. 由于比较熟悉linux的操作. 部门里碰到的线上bug或者一些日志的分析, 大部分都会找我去搞.

5. 做项目非常快, 而且bug少, 常常拉去救火, 各个team碰到紧急的项目, 会被临时抽调过去, 往往能比其他人解决近一半的开发时间. 甚至还写过ios客户端(这个请忽略, 真没兴趣做手机开发).

---

### 2012/12 - 2014/04: [唯品会](http://www.vip.com) Java开发工程师

参与了应用平台几乎所有项目(比价爬虫, [Storm](https://storm.apache.org/), 招商选品, [passport](http://passport.vip.com/), user_api, [user_center](http://myi.vip.com), reco_api)的设计工作, 并对每个参与过的项目中, 对代码整体质量都有较大的正面影响, 我们的项目代码被拿到广州总部做为代码质量的典范去做推广. 在开发和维护期间, 没有出过重大线上事故; 对跨部门的合作中也一直保持积极配合和快速响应. 近期对[user_center](http://myi.vip.com), user_api和reco_api等核心业务提供技术支持和维护. 对内, 与同事保持融洽的同事关系, 对新进员工提供必要和耐心的指导. 对外, 与广发银行保持积极合作态度, 并和对方开发人员也保持不错的朋友关系. 

**开发工具:** Spring, SpringMVC, Mybatis, MySql, [Thrift](https://thrift.apache.org/), Redis, [RestEasy](http://resteasy.jboss.org/), Freemarker

**责任描述:** 只要和用户相关的系统和服务, 都和我有关系

**项目描述:** 上海入职最早的Java开发工程师, 所以参与过我们项目组上海几乎所有的项目的从无到有的开发过程. 列举几个:

1. passport: 用户登录系统 [https://passport.vip.com](https://passport.vip.com), 用户登录/注册, 联合登录等功能的系统, 之前是PHP逻辑, 全部用Java重新做, 这是第一个上海团队比较大型的Java开发项目, 今后入职的很多同事也都是从这个团队入手, 培养起一套良好的开发习惯. (Spring/SpringMVC/Mybatis/Freemarker/Mysql/Redis/[Thrift](https://thrift.apache.org/))

2. user_center: 用户中心系统 [http://myi.vip.com](http://myi.vip.com), 之前是PHP逻辑, 全部用Java重新做, 并在熟悉之前逻辑的基础上, 完成大量重构以及逻辑优化工作. (Spring/SpringMVC/Mybatis/Freemarker/Mysql/Redis/[Thrift](https://thrift.apache.org/))

3. user_api: 内网一整套 [RESTful](https://zh.wikipedia.org/wiki/REST)风格的接口的系统, 提供长期的业务和数据支持. 几乎所有的和用户数据相关的对内接口需求全部从这里放出去. Spring/[RestEasy](http://resteasy.jboss.org/)/Mybatis/Mysql/Redis

4. reco_api: 内网一套判断用户级别的接口系统, 业务简单没什么好说, 但并发量在高峰达到QPS 1.6w以上, 从代码到部署上对项目的要求也非常高. (Spring/Redis)

5. 其他乱七八糟的java项目...比如 [Storm](https://storm.apache.org/) 的实时分析, 招商选品平台等等.

---

### 2010/02 – 2012/08: [PPTV](http://www.pptv.com) Web后端开发工程师

**开发工具:** MySql, Memcache, Lucene, [PHPRPC](http://www.phprpc.org/zh_CN/), [Thrift](https://thrift.apache.org/), Spring

**责任描述:** 后台开发, 对外接口, 各平台接口, Drag中心, 搜索网站 

**项目描述:** 参与多个项目开发, 随便说几个: 

1. Passport: 用户登录系统 [http://passport.pptv.com](http://passpot.pptv.com), 涉及网站, 客户端, vip系统, 手持移动设备以及网站本身的连接. 进行了半年的开发和维护工作. (Mysql/Spring/iBatis/Struts/TokyoTyrant/MemCache)

2. 站外推广合作接口: 站外流量推广, 从11年中旬至今, 从项目起步已发展至56家合作方(含Google/百度/腾讯/360/好123/搜狗/迅雷/华数等), 200多种接口格式, 为网站带来大量的站外流量. (SpringJDBC/MySql)

3. EPG后台: 11年上半年基础片库, 向下涉及和压片制片逻辑的关联, 向上与内部接口关联, 由于设计个各平台的业务特殊需求, 需要对后台业务逻辑非常的熟悉, 同时随着业务的不断变化, Epg后台也在不断进行着各种功能修改. (SpringJDBC/JSP/MySql)

4. 内部接口: 网站/客户端/移动终端/机顶盒等大量接口开发工作, 如详情页, 列表页, 排行榜, 播放页等数据支持, 除了对也许需要高度熟悉, 还要兼并考虑性能和并发等难点. (Spring/[PhpRPC](http://www.phprpc.org/zh_CN/)/MySql/MemCache)

5. 江苏有线视频搜索网站: 一个和江苏电视台合作的项目, 设计基于Lucene的搜索网站. 网站爬虫, 索引逻辑, 搜索接口开发仅我一个人. (Lucene/MySql/[Phprpc](http://www.phprpc.org/zh_CN/))

6. Drag中心: 视频拖动信息文件管理, 和所有平台播放息息相关, 对稳定性要求非常高, 一旦出错, 全平台瘫痪. (MySql/[Thrift](https://thrift.apache.org/)/Memcache)

7. 后台爬虫系统: 第三方视频服务网站的页面爬虫系统, 抓取和筛选其他视频网站的视频资源. (MySql/[Thrift](https://thrift.apache.org/)/Memcache)

