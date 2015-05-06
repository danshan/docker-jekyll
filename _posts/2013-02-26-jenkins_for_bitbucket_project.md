---
layout: post
title: 使用 jenkins 对 bitbucket 上的私人项目作持续集成
date: 2013-02-26 17:27
description: "本文实现了使用个人架设的 jenkins 服务器对的 bitbucket 中的私人项目作持续集成, 项目使用 git 作版本控制, maven 作构建管理"
category: Tech
tags: [jenkins, bitbucket, maven, git]
---
我有几个放置在 [Bitbucket](https://bitbucket.org/) 上的私人项目, 以及一台放置在香港的 [Linode](http://www.linode.com/) vps, 想在这台 linode 上部署一个 [jenkins](http://jenkins-ci.org/) 服务, 实现对 bitbucket 上的这些项目作持续集成. 下面来说流程, 基于目前最新的1.502版本.

至于怎么安装 jenkins 以及怎么配置 resin/nginx 等服务, 不在本文的讨论范围, 这里关注的重点在于配置 bitbucket 项目.

## 配置 Jenkins

首先, 解决安全问题, 既然 bitbucket 上的项目是私人的, jenkins 自然也不能开放公共权限. 我们要设置 jenkins.

通过左上角进入系统配置菜单: _Jenkins_ > _Manage Jenkins_ > _Configure Global Security_, 勾选 _Enable security_, 下面_Security Realm_支持了四种安全策略, 我们选择最简单的 _Jenkins's own user database_, 但不要勾选下面的 _Allow users to sign up_.

![manage jenkins](/assets/post/2013/02/manage_jenkins.png)

在下面的 _Authorization_ 中选择 _Project-based Matrix Authorization Strategy_, 以获得最灵活的权限控制功能. 配置完成后, 把jenkins重启, 这个时候会提示要求输入用户名和密码, 由于是第一次登录, 直接点击左上角 _jenkins_, 这里提示了注册功能, 注册唯一的管理员用户. 注册完成后就能登录了, 之后可以再次进入刚刚的 _Configure Global Security_ 配置用户权限.

## 导入 Bitbucket 项目

配置好了 jenkins, 我们下面来创建指向 bitbucket 的项目. Jenkins 中点击 _New Job_, 设置 _Job name_ 并选择 _Build a free-style software project_. 下面进入了项目的配置页面, 最主要的几个地方是:

* Source Code Management

这里当然选择 Git. 但是要注意一点, jenkins 不支持 HTTPS 方式, 所以我们必须在 bitbucket 中找到项目的 SSH 地址, 而且同时我们也要在jenkins的服务器上生成 ssh key. 这里简单介绍步骤:

登录 linode 服务器, 执行下面的命令生成 ssh key:

{% highlight bash %}
$ ssh-keygen -t rsa
{% endhighlight %}

![ssh-keygen](/assets/post/2013/02/ssh_keygen.png)

默认生成的key会保存在 _~/.ssh/id_rsa.pub_, 我们把内容 cat 出来并复制.

{% highlight bash %}
$ cat ~/.ssh/id_rsa.pub
{% endhighlight %}

进入 bitbucket 的项目配置页面, 在 _Deployment keys_ 点击 _Add key_, Label 随便写, Key 中粘贴前面复制出来的 id_rsa.pub 的内容.

保存后进入 bitbucket 的项目主页, 查看项目的 SSH 地址, 点击 HTTPS 下拉选择 SSH, 地址格式为 git@bitbucket.org:<user_name>/<project_name>.git, 把这个地址填到 jenkins 中项目配置页的 Git Repositories 里. _Branches to build_ 可以填 master, 不填则默认是最后 push 的 branch.

![ssh-keygen](/assets/post/2013/02/bitbucket_ssh.png)

下面来配置顶起 build 的周期, 我选择的做法是勾选 _Build Triggers_ 的 _Poll SCM_ , 填入 `* * * * *`, 这样让 jenkins 每分钟检查一次 bitbucket, 如果有新的修改, 则自动 build.

![ssh-keygen](/assets/post/2013/02/jenkins_poll_scm.png)

到此, 就完成了所有关于 jenkins 的配置, 点击左边的 **Build Now**试试看吧.

![ssh-keygen](/assets/post/2013/02/jenkins_build_now.png)
