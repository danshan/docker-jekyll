---
layout: post
title: Maven打包非web项目时包含第三方jar包
date: 2012-07-30 17:49
description: 非web项目中, 默认使用`maven install`时, 并不会将项目依赖的jar包打包放进项目中, 需要对pom.xml做如下修改, 使得target目录下包含完整依赖关系的可部署文件夹.
tags: [maven, java]
image:
  feature: abstract-6.jpg
  credit: dargadgetz
  creditlink: http://www.dargadgetz.com/ios-7-abstract-wallpaper-pack-for-iphone-5-and-ipod-touch-retina/
---

非web项目中, 默认使用`maven install`时, 并不会将项目依赖的jar包打包放进项目中, 需要对pom.xml做如下修改:
{% highlight xml %}
<build>
  <plugins>
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-dependency-plugin</artifactId>
      <executions>
        <execution>
          <id>copy-dependencies</id>
          <phase>package</phase>
          <goals>
            <goal>copy-dependencies</goal>
          </goals>
          <configuration>
            <outputDirectory>${project.build.directory}/lib</outputDirectory>
            <overWriteReleases>false</overWriteReleases>
            <overWriteSnapshots>false</overWriteSnapshots>
            <overWriteIfNewer>true</overWriteIfNewer>
          </configuration>
        </execution>
      </executions>
    </plugin>
  </plugins>
</build>
{% endhighlight %}
