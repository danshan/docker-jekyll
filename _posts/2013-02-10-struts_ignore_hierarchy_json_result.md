---
layout: post
title: Struts 返回 json 格式时缺少父类属性问题解决
date: 2013-02-10 13:27
description: "通过 struts 搭配 json 插件, 直接返回 json 对象可以大大简化程序对返回格式进行手动格式化的操作, 然而, 也碰到一个问题, 如果 result 中用于生成 json 格式的对象如果继承了某个对象, 输出的 json 格式中并不会包含父类的属性."
category: Tech
tags: [struts, json]
---
通过 struts 搭配 json 插件, 直接返回 json 对象可以大大简化程序对返回格式进行手动格式化的操作, 然而, 也碰到一个问题, 如果 result 中用于生成 json 格式的对象如果继承了某个对象, 输出的 json 格式中并不会包含父类的属性.

举例来说, 我们完成用户注册和登录的功能, 返回的 json 格式都需要包含一个状态码 'status', 除此以外登录还要返回用户的详细信息, 而注册只要返回用户的精简信息, 我们这时候考虑吧返回的 Result 抽象成一个对象, 注册和登录的返回值分别继承这个 Result.

示例代码:

{% highlight java %}
public class BaseResult {
    public static final int SUCCESS = 0;
    public static final int ERROR = 1;

    public int status;
}

public class LoginResult extends BaseResult {
    public UserDetail detail; // 用户的详细信息
}

public class RegisterResult extends BaseResult {
    public UserInfo info; // 用户的简要信息
}
{% endhighlight %}

我们在 action 中这样配置

{% highlight java %}
@Namespace("/")
@ParentPackage("json-default")
@Action("register")
@Results({
    @Result(name="success", type="json", params={"root", "result"})
})
public class RegisterAction extends ActionSupport {
    
    public RegisterResult result = new RegisterResult();

    @Override
    public String execute() throws Exception {
        result.status = BaseResult.SUCCESS;
        result.info = null;

        return SUCCESS;
    }

}
{% endhighlight %}

查看调用 action 的结果, 发现 register 操作只返回了 RegisterResult中的 info, 而并没有返回 BaseResult 中的 status:

{% highlight json %}
{
    "info": null
}
{% endhighlight %}

原因是 status 的 json 插件默认并不会返回被继承父类的属性, 如果需要返回, 则要收到打开这个开关, 方式是在 @Results 注解中添加一组参数: `"ignoreHierarchy", "false"`:

{% highlight java %}
@Results({
    @Result(name="success", type="json", 
            params={"root", "result", "ignoreHierarchy", "false"})
}
{% endhighlight %}

这样, 就成功的返回了 BaseResult中的 status.
