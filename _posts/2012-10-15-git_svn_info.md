---
layout: post
title: 为 git 实现 'svn info' 的功能
date: 2012-10-15 14:27
description: "git没有类似svn中的`svn info`功能, 由于一些特殊的需求, 需要自己写一个脚本来实现这样的功能"
tags: [git, svn, linux]
image:
  feature: abstract-12.jpg
  credit: dargadgetz
  creditlink: http://www.dargadgetz.com/ios-7-abstract-wallpaper-pack-for-iphone-5-and-ipod-touch-retina/
---
git没有类似svn中的'svn info'功能, 自己写一个脚本来实现这样的功能:

{% highlight bash %}
#!/bin/sh

# Find base of git directory
while [ ! -d .git ] && [ ! `pwd` = "/" ]; do cd ..; done

# Show various information about this git directory
if [ -d .git ]; then
    echo "== Remote URL: `git remote -v`"

    echo "== Remote Branches: "
    git branch -r
    echo
    echo "== Local Branches:"
    git branch
    echo
    echo "== Configuration (.git/config)"
    cat .git/config
    echo
    echo "== Most Recent Commit"
    git --no-pager log --max-count=1
    echo
    echo "Type 'git log&' for more commits, or 'git show' for full commit details."
else
    echo "Not a git repository."
fi
{% endhighlight %}

运行效果如下:

    == Remote URL: origin https://danshan@bitbucket.org/danshan/haidaofm.git (fetch)
    origin https://danshan@bitbucket.org/danshan/haidaofm.git (push)
    == Remote Branches:
    origin/HEAD -> origin/master
    origin/master

    == Local Branches:
    * master

    == Configuration (.git/config)
    [core]
    repositoryformatversion = 0
    filemode = true
    bare = false
    logallrefupdates = true
    [remote "origin"]
    fetch = +refs/heads/*:refs/remotes/origin/*
    url = https://danshan@bitbucket.org/danshan/haidaofm.git
    [branch "master"]
    remote = origin
    merge = refs/heads/master

    == Most Recent Commit
    commit 843423895f429aa6d78be1b2d26fb93472c64548
    Author: Dan Shan
    Date: Mon Oct 15 07:12:33 2012 +0400

    webapi
    [bugfix]
    1. fix some import error of java

    Type 'git log' for more commits, or 'git show' for full commit details.

<a href="{{ site.cdn }}/files/2012/10/gitinfo.zip" class="btn btn-info"><i class="icon-download icon-white"></i> 下载 gitinfo.zip</a>
