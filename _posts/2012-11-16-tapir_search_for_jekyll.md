---
layout: post
title: 使用Tapir实现jekyll的站内搜索功能
date: 2012-11-16 22:35
description: "要在jekyll搭建的静态网站中实现站内搜索, 网上给出的解决方案基本都是**google custom search**, 但是这个方案不但有广告, 想修改css的时候又非常的复杂, 难以下手. 下面提供另一种非常简便的站内搜索解决方案--**Tapir**"
category: Tech
tags: [jekyll, tapir, search, rss, lucene, jquery]
---

要在jekyll搭建的静态网站中实现站内搜索, 网上给出的解决方案基本都是**google custom search**, 但是这个方案不但有广告, 想修改css的时候又非常的复杂, 难以下手. 下面提供另一种非常简便的站内搜索解决方案--[Tapir](http://tapirgo.com/).

先简单介绍一下[Tapir](http://tapirgo.com/),  [Tapir](http://tapirgo.com/)是通过你的网站的RSS feed来创建索引, 并且使用[Tire](https://github.com/karmi/tire) (Powered by [Elasticsearch](http://www.elasticsearch.org/), 而底层的实现, 就是大名鼎鼎的[Lucene](http://lucene.apache.org/))进行索引并实现搜索的简洁的应用. 并通过JSON API返回搜索的结果.

通过在Tapir官方网站注册RSS feed后获取的token, 进行搜索, 返回的json格式如下:

{% highlight js %}
[
  {
    "title":"Capybara ate Swinger",
    "published_on":"2011-02-07T05:00:00Z",
    "content": [the full article content],
    "link":"http://jeffkreeftmeijer.com/2011/capybara-ate-swinger",
    "summary":"Remember Swinger, the Capybara RSpec driver swapper? Capybara can now swap drivers out of the box.",
    "_score":61.15513
  }
]
{% endhighlight %}

你可以现在本站测试一下站内搜索, 中文支持的也非常出色. 下面说一下完整的实现方案:

1\. 修改RSS feed格式

编辑你的网站文件夹下的atom.xml(或者别的什么名字的文件), 最好在格式`entry`里加上`summary`, 也就是每篇blog的摘要部分, 在搜索结果中展现blog的摘要要比给出全文美观的多.

{% highlight xml %}
 <entry>
   <title>{ { post.title } }</title>
   <link href="{ { site.production_url } }{ { post.url } }"/>
   <updated>{ { post.date | date_to_xmlschema } }</updated>
   <id>{ { site.production_url } }{ { post.id } }</id>
   <content type="html">{ { post.content | xml_escape } }</content>
   <summary type="html">{ { post.description | xml_escape } }</summary>
 </entry>
{% endhighlight %}

    注意: 上面双大括号之间不应有空格, 我是为了现在显示不会被转意才这么写.

2\. 登录[Tapir官方网站](http://tapirgo.com/)注册你的rss feed, 会返回给你一个token, 记下它.

3\. 在模板中给你的网页上下个search框吧, 我用的是jekyllbootstrap框架, 加入这个功能非常容易: 

{% highlight html %}
<form class="navbar-search pull-right" action="search.html">
  <input type="text" class="search-query" placeholder="Search">
</form>
{% endhighlight %}

由于搜索用到了jquery, 需要加入jquery的js和一个处理tapir搜索过程的js(这个功能比较简单, 当然你也可以自己去实现或修改)

{% highlight html %}
<script src="/assets/themes/dan/js/jquery.min.js"></script>
<script src="/assets/themes/dan/js/jquery-tapir.min.js"></script>
{% endhighlight %}

{% highlight javascript %}
(function($) {
    var el;
    var settings = {};
    var methods = {
        init: function(options) {
            el = this;
            settings = {
                token: false,
                query_param: 'query'
            };
            if(options) {
                $.extend(settings, options);
            }
            if(!settings.token || settings.query_param == '') {
                return this;
            }
            $.getJSON('http://tapirgo.com/api/1/search.json?token=' + settings.token 
                        + '&query=' + paramValue(settings.query_param) + '&callback=?',
                    function(data) {
                if(settings['complete']) {
                    settings.complete()
                }
                $.each(data, function(key, val) {
                    el.append('<div class="result"><h3><a href="' + val.link + '">' 
                        + val.title + '</a></h3><p>' + val.summary + '</p></div>');
                });
            });
            return this;
        }
    };

    function paramValue(query_param) {
        var results = new RegExp('[\\?&]' + query_param 
                + '=([^&#]*)').exec(window.location.href);
        return results ? results[1] : false;
    }
    $.fn.tapir = function(method) {
        if(methods[method]) {
            return methods[method].apply(this, Array.prototype.slice.call(arguments, 1));
        } else if(typeof method === 'object' || !method) {
            return methods.init.apply(this, arguments);
        } else {
            $.error('Method ' + method + ' does not exist on jQuery.tapir');
        }
    };
})(jQuery);
{% endhighlight %}

<a href="/assets/post/2012/11/jquery-tapir.min.js.zip" class="btn btn-info"><i class="icon-download icon-white"></i> 下载 jquery-tapir.min.js.zip</a>

由于search.html是在加载时直接执行搜索, 所以这两个js文件必须在header中加载.

4\. 上面一部form的action为**search.html**, 下面我们就创建这个页面
{% highlight html %}
---
layout: page
title: Pages 
header: Pages
---

<h2>Search Results</h2>
  <div id="search_results"></div>
<script>
  $('#search_results').tapir({'token': '50a61c823f61b0346e0003a4'});
</script>
{% endhighlight %}

    token填入前面注册返回的token值.

完成了以上几个步骤, 你的站内搜索已经搭建成功了, 相比google custom search来说, 最大的长处在于, 你可以自由的修改search box和result的样式, 而不用受到google的各种限制.
