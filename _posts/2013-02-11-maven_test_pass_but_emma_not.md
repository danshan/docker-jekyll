---
layout: post
title: 解决 maven 执行 test 可以跑通而 emma 失败问题
date: 2013-02-11 18:27
description: "在一个项目里发现引用了 JCaptcha 包以后, 原有的`mvn emma:emma`执行就失败了, 折腾了好久才解决, 下面来说说解决思路"
category: Tech
tags: [spring, jcaptcha, maven, emma]
---
在一个项目里发现引用了 JCaptcha 包以后, 执行`mvn test`一切正常, 而原有的`mvn emma:emma`执行就失败了, 抛出下面的异常:

{% highlight bash %}
-------------------------------------------------------------------------------
Test set: com.vipshop.passport.action.LoginActionTest
-------------------------------------------------------------------------------
Tests run: 1, Failures: 0, Errors: 1, Skipped: 0, Time elapsed: 0.135 sec <<< FAILURE!
initializationError(com.vipshop.passport.action.LoginActionTest)  Time elapsed: 0.004 sec  <<< ERROR!
java.lang.NoSuchMethodError: org.springframework.core.annotation.AnnotationUtils.findAnnotationDeclaringClass(Ljava/lang/Class;Ljava/lang/Class;)Ljava/lang/Class;
	at org.springframework.test.context.TestContext.retrieveContextLoaderClass(TestContext.java:166)
	at org.springframework.test.context.TestContext.<init>(TestContext.java:121)
	at org.springframework.test.context.TestContextManager.<init>(TestContextManager.java:117)
	at org.springframework.test.context.junit4.SpringJUnit4ClassRunner.createTestContextManager(SpringJUnit4ClassRunner.java:120)
	at org.springframework.test.context.junit4.SpringJUnit4ClassRunner.<init>(SpringJUnit4ClassRunner.java:108)
	at sun.reflect.NativeConstructorAccessorImpl.newInstance0(Native Method)
	at sun.reflect.NativeConstructorAccessorImpl.newInstance(NativeConstructorAccessorImpl.java:39)
	at sun.reflect.DelegatingConstructorAccessorImpl.newInstance(DelegatingConstructorAccessorImpl.java:27)
	at java.lang.reflect.Constructor.newInstance(Constructor.java:513)
	at org.junit.internal.builders.AnnotatedBuilder.buildRunner(AnnotatedBuilder.java:31)
	at org.junit.internal.builders.AnnotatedBuilder.runnerForClass(AnnotatedBuilder.java:24)
	at org.junit.runners.model.RunnerBuilder.safeRunnerForClass(RunnerBuilder.java:57)
	at org.junit.internal.builders.AllDefaultPossibilitiesBuilder.runnerForClass(AllDefaultPossibilitiesBuilder.java:29)
	at org.junit.runners.model.RunnerBuilder.safeRunnerForClass(RunnerBuilder.java:57)
	at org.junit.internal.requests.ClassRequest.getRunner(ClassRequest.java:24)
	at org.apache.maven.surefire.junit4.JUnit4TestSet.execute(JUnit4TestSet.java:51)
	at org.apache.maven.surefire.junit4.JUnit4Provider.executeTestSet(JUnit4Provider.java:123)
	at org.apache.maven.surefire.junit4.JUnit4Provider.invoke(JUnit4Provider.java:104)
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:39)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:25)
	at java.lang.reflect.Method.invoke(Method.java:597)
	at org.apache.maven.surefire.util.ReflectionUtils.invokeMethodWithArray(ReflectionUtils.java:164)
	at org.apache.maven.surefire.booter.ProviderFactory$ProviderProxy.invoke(ProviderFactory.java:110)
	at org.apache.maven.surefire.booter.SurefireStarter.invokeProvider(SurefireStarter.java:175)
	at org.apache.maven.surefire.booter.SurefireStarter.runSuitesInProcessWhenForked(SurefireStarter.java:107)
	at org.apache.maven.surefire.booter.ForkedBooter.main(ForkedBooter.java:68)
{% endhighlight %}

之前一只猜想是不是 JCaptcha 的包有问题, 但是从报错信息上看, 却又好像和 JCaptcha 没有任何关系. 仔细查看日志, 看到最有用的一行:

    java.lang.NoSuchMethodError: org.springframework.core.annotation.AnnotationUtils.findAnnotationDeclaringClass(Ljava/lang/Class;Ljava/lang/Class;)Ljava/lang/Class;

说是**AnnotationUtils**类中找不到**findAnnotationDeclaringClass**方法, 但是执行`mvn test`的却没有问题, 初步判断, 会不会是由于 spring 版本冲突导致 test 和 emma 执行时使用的不是相同版本的 spring.

接下来去验证这个问题, 通过下面的命令查看项目依赖的各个包的版本:

{% highlight bash %}
mvn dependency:tree
{% endhighlight %}

看到下面的结果:

{% highlight bash %}
[INFO] com.vipshop:passport_service:war:0.0.1
[INFO] +- org.springframework:spring-core:jar:3.0.5.RELEASE:compile
[INFO] |  +- org.springframework:spring-asm:jar:3.0.5.RELEASE:compile
[INFO] |  \- commons-logging:commons-logging:jar:1.1.1:compile
[INFO] +- com.octo.captcha:jcaptcha-all:jar:1.0-RC6:compile
[INFO] |  +- quartz:quartz:jar:1.5.1:compile
[INFO] |  +- commons-dbcp:commons-dbcp:jar:1.2.1:compile
[INFO] |  |  \- xml-apis:xml-apis:jar:1.0.b2:compile
[INFO] |  +- commons-pool:commons-pool:jar:1.3:compile
[INFO] |  +- net.sf.ehcache:ehcache:jar:1.2.4:compile
[INFO] |  +- concurrent:concurrent:jar:1.3.4:compile
[INFO] |  +- org.springframework:spring:jar:2.0:compile
[INFO] |  +- xerces:xercesImpl:jar:2.5.0:compile
[INFO] |  \- xerces:xmlParserAPIs:jar:2.2.1:compile
{% endhighlight %}

确实看到我们用的**org.springframework:spring-core:jar**是_3.0.5_而 jcaptcha 引用的**org.springframework:spring:jar**是_2.0_版.
我们需要屏蔽 jcaptcha 中的这个 spring, 让它使用 3.0.5 的依赖, 我们直接修改 pom.xml 中关于 jcaptcha 的 dependency:

{% highlight xml %}
<dependency>
  <groupId>com.octo.captcha</groupId>
  <artifactId>jcaptcha-all</artifactId>
  <version>1.0-RC6</version>
  <exclusions>
    <exclusion>
      <artifactId>spring</artifactId>
      <groupId>org.springframework</groupId>
    </exclusion>
  </exclusions>
</dependency>
{% endhighlight %}

之后再次执行`mvn emma:emma`, 已经可以正常跑通了.
