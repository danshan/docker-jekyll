---
layout: post
title: 在vim做粘贴操作时禁用自动缩进和智能缩进
date: 2012-11-16 11:35
description: "vim的自动缩进和智能缩进功能给在vim下做开发的程序员提供了非常大的便利, 但在做代码粘贴的时候, 如果被粘贴的文字中带有tab, 整个粘贴后的格式会乱掉, 需要开启一些特殊设置."
category: Vim
tags: [vim, paste, indent]
---

vim的自动缩进和智能缩进功能给在vim下做开发的程序员提供了非常大的便利, 但在做代码粘贴的时候, 如果被粘贴的文字中带有tab, 整个粘贴后的格式会乱掉.

看到一些论坛, 很多vimer也碰到同样的问题, 给出的答案是禁用自动缩和智能缩进功能: .vimrc添加如下配置

{% highlight vim %}
set noai
set nosi
{% endhighlight %}

但是这样设置之后依然没有解决问题. 继续查资料, 发现还有另外一个设置:

{% highlight vim %}:set paste {% endhighlight %}

开打**paste**模式以后, 粘贴问题缩进问题立刻就解决了, 查看帮助, 会发现paste模式做了如下操作:

    When the 'paste' option is switched on (also when it was already on):
            - mapping in Insert mode and Command-line mode is disabled
            - abbreviations are disabled
            - 'textwidth' is set to 0
            - 'wrapmargin' is set to 0
            - 'autoindent' is reset
            - 'smartindent' is reset
            - 'softtabstop' is set to 0
            - 'revins' is reset
            - 'ruler' is reset
            - 'showmatch' is reset
            - 'formatoptions' is used like it is empty
    These options keep their value, but their effect is disabled:
            - 'lisp'
            - 'indentexpr'
            - 'cindent'

设置了这么多选项, 怪不得只关闭ai和si没有用.

但是这样还是比较麻烦, 难道每次粘贴前都要先执行`set paste`, 粘贴完成后在执行`set nopaste`么? 当然不行, 下面要绑定快捷键, .vimrc中添加如下配置:

{% highlight vim %}
map <F10> :set paste<CR>
map <F11> :set nopaste<CR> 
{% endhighlight %}

这样, 每次粘贴前, 先按**F10**进入paste模式, 粘贴后再按**F11**退出粘贴模式, 但是这样又占用了两个快捷键, 也不是很方便. 其实, paste有一个切换paste开关的选项, 这就是pastetoggle. 通过它可以绑定快捷键来激活/取消paste模式. 比如:

{% highlight vim %}
set pastetoggle=<F11>
{% endhighlight %}

这样减少了一个快捷键的占用, 使用起来也更方便一些.
