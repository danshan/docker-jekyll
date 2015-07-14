---
layout: post
title: "通过 markdown 和 freemarker 渲染邮件"
date: 2015-05-25 10:14
description: "部门要做一个简单的提测邮件模板, 取代每次提测时都要手动发邮件的功能, 我实现其中一部分文字渲染的功能. 通过 markdown 语法对提测内容进行格式化"
tags: [java, freemarker, markdown]
image:
  feature: abstract-3.jpg
  credit: dargadgetz
  creditlink: http://www.dargadgetz.com/ios-7-abstract-wallpaper-pack-for-iphone-5-and-ipod-touch-retina/
---

部门要做一个简单的提测邮件模板, 取代每次提测时都要手动发邮件的功能, 我实现其中一部分文字渲染的功能. 通过 [markdown](http://daringfireball.net/projects/markdown/) 语法对提测内容进行格式化.

之前的邮件模板是

<img src="{{ site.cdn }}/files/2015/05/md-01.png{{ site.img }}">

可见非常的丑陋.

由于我自己喜欢用markdown语法写邮件, 对这种table的表格信息非常反感, 决定稍稍修改一下提交的样式.

第一步是解决 java 渲染 markdown 语法的问题, 这个好办, 我用的这个库 [markdownpapers-doxia-module](http://markdown.tautua.org/doxia-module.html), maven 的 repo 在[这里](http://mvnrepository.com/artifact/org.tautua.markdownpapers/markdownpapers-doxia-module).

接下来是解决生成好了的 html 如何美化. 当然你可以自己去写 css, 我前端功底太差, 实在搞不定. 我是从 [MOU][http://25.io/mou/] 这个 markdown 编辑器中导出了一份 css 文件(这里推荐一下这个软件, 真的非常好用, 如果能后同步到 evernote 就更好了).

<img src="{{ site.cdn }}/files/2015/05/md-02.png{{ site.img }}">

代码这里就不贴了, 需要的自己下载: 

* [Clearness Dark.css]({{ site.cdn }}/files/2015/05/Clearness%20Dark.css) 
* [Clearness.css]({{ site.cdn }}/files/2015/05/Clearness.css)
* [CGitHub.css]({{ site.cdn }}/files/2015/05/GitHub.css)
* [GitHub2.css]({{ site.cdn }}/files/2015/05/GitHub2.css)

我处理渲染的逻辑是, 首先把需要提交的数据全部渲染到一个 markdown 文件, 然后再把这个 markdown 文件渲染到 email 正文中. 那么这里需要自己去设计两个文件:

**1\. markdown 文件的模板 template/emailTemplate.md **

这个很简单, 把需要用户填写的地方留出来就行了:

<pre>
# [提测] ${req.projectName!"unknow"}

> **开发人员:** ${req.projectLeader!"unknow"}

> **测试人员:** ${req.qaName!"unknow"}

> **产品经理:** ${req.pmName!"unknow"}

---

## 相关需求

${req.demand!""}

## Release Notes

${req.releaseNotes!""}

## 测试要点

${req.testMainPoints!""}

## 相关信息

* 相关应用: ${req.relatedApps!"unknow"}

* 上线时间: ${req.plannedTime?string["yyyy-MM-dd hh:mm:ss"]}

## 备注

${req.otherRemark!"无"}
</pre>

** 2\. email html 的模板 template/emailTemplate.ftl **

{% highlight html %}
<html>
<head>
    <title></title>

    <meta charset="utf-8">

    <style>
    </style>
</head>

<body>

${content}

</body>
</html>
{% endhighlight %}

需要注意的是, 这个 html 中由于 blog 篇幅的限制, 我这里把css的配置删掉了, 由于 email 无法 link 外部的 css文件, 所以需要把前面下载的 css 文件的内容贴到 `<style></style>` 中间.

下面就是需要需要提交到页面上的数据类

{% highlight java %}
public class TestNoticeBean implements Serializable {

    private String projectName;   //项目名

    private String projectLeader;   //项目负责人

    private String qaName;   //QA负责人

    private String pmName;   //PM负责人

    private String releaseNotes;   //上线要点

    private String demand;   //需求

    private String testMainPoints;    //测试要点

    private String relatedApps;  //相关应用

    private Date plannedTime;     //上线时间

    private String otherRemark;     //其他

}
{% endhighlight %}

不管是渲染 markdown 还是最后的渲染 html, 都是使用了 freemarker 内置的方法.

{% highlight java %}

import freemarker.template.Configuration;
import freemarker.template.Template;

import java.io.BufferedWriter;
import java.io.StringWriter;
import java.util.Locale;

public class ClassPathTemplateRender implements TemplateRender {
    private static Configuration config = null;

    public static ClassPathTemplateRender getInstance(){
        return new ClassPathTemplateRender();
    }

    public ClassPathTemplateRender(){
        if(config == null){
            config = new Configuration();
            config.setClassForTemplateLoading(this.getClass(), "/"); //第二个参数指定模板所在的根目录，必须以“/”开头。

            try{
                config.setSetting("datetime_format", "yyyy-MM-dd HH:mm:ss");
                config.setLocale(Locale.CHINA);

            }catch(Exception ex){
                ex.printStackTrace();
            }
        }
    }

    public String render(Object dataModel, String ftlFile) throws Exception {
        StringWriter stringWriter = new StringWriter();
        BufferedWriter writer = new BufferedWriter(stringWriter);
        Template template = config.getTemplate(ftlFile, Locale.CHINA, "UTF-8");
        template.process(dataModel,writer);
        writer.flush();

        return stringWriter.toString();
    }
}

public class FtlUtil {
    public static String renderFile(Object dataModel, String ftlFile)throws Exception{
        String ret = ClassPathTemplateRender.getInstance().render(dataModel, ftlFile);
        return ret;
    }
}
{% endhighlight %}

最后的渲染逻辑在下面

{% highlight java %}
Map<String, Object> paramsForMd = new HashMap<String, Object>();
paramsForMd.put("req", testNoticeBean);

String md = FtlUtil.renderFile(paramsForMd, "template/emailTemplate.md");

Reader in = new StringReader(md);
Writer out = new StringWriter();

Markdown markdown = new Markdown();
markdown.transform(in, out);

Map<String, Object> paramsForFtl = new HashMap<String, Object>();
paramsForFtl.put("content", out.toString().replaceAll("<code>", "<pre>").replaceAll("</code>", "</pre>"));
System.out.println(FtlUtil.renderFile(paramsForFtl, "template/emailTemplate.ftl"));
{% endhighlight %}

最后那个把 `<code>` 转成 `<pre>`, 主要是因为 markdown 渲染后的代码块用的是 `<code>`, 但是会碰到渲染到 html 时, 换行符就没了, 所以中间又转了一次.