---
layout: post
title: mobileapi 项目引入 drools 规则引擎
date: 2015-05-08 15:20
description: "对于很多复杂业务逻辑, 把一些经常修改和定制的业务逻辑交给 drools 处理"
tags: [mobileapi drools java]
image:
  feature: abstract-1.jpg
  credit: dargadgetz
  creditlink: http://www.dargadgetz.com/ios-7-abstract-wallpaper-pack-for-iphone-5-and-ipod-touch-retina/
---

目前我们最新上线的 **mobileapi**(用于给手机客户端提供接口服务) 项目已经引入了 JBoss 的 [Drools](http://www.drools.org/) 规则引擎

在介绍项目的上下文之前 我们先看看我们之前代码中存在的各种膈应人的逻辑:

1. 亲子购物和亲子游乐的 7.2.0 版本, 产品页显示团购推荐模块, 同时隐藏热卖产品模块...
2. 产品详情页的预约按钮文案, 旅游婚纱显示"咨询有礼"; 幼儿教育和早教中心如果存在"试听"的tag, 则显示"预约试听"; 女士婚纱/旗袍/晚礼服/龙凤褂如滚存在"0元试听"标签则显示"预约试纱", 默认显示"预约看店"...
3. 商户页亲子购物/亲子游乐分类在7.2.0版本, 产品推荐模块显示2个产品, 否则显示4个产品...
4. 旅游婚纱的判断渗透到各个接口中...

于是, 代码中会出现各种各样的 `fuck` 字眼, 当然大部分都是我写的, 原谅我是个脾气暴躁的死程序员...

{% highlight java %}
// 20141222 对于旅游婚纱产品, 显示为咨询有礼
if (Constants.PCATE_TRAVELWED == productCategoryId) {
    return "咨询有礼";
}
if (CollectionUtils.isNotEmpty(propList)) {
    for (Map<String, Object> pro : propList) {
        if (MapUtils.isEmpty(pro)) {
            continue;
        }
        Object nameIdObj = pro.get("nameId");
        if (nameIdObj != null) {
            int nameId = Integer.valueOf(nameIdObj.toString());
            List<String> value = (List<String>) pro.get("value");
            switch (nameId) {
                case 2776316://幼儿才艺-有无试听
                case 2776116://早教中心-有无试听
                    if (CollectionUtils.isNotEmpty(value) && "有".equals(value.get(0))) {
                        return "预约试听";
                    }
                    return "预约看店";
                case 2541120://女士婚纱-0元试纱
                case 98315://晚礼服-0元试纱
                case 101615://旗袍/龙凤褂-0元试纱
                    if (CollectionUtils.isNotEmpty(value) && "有".equals(value.get(0))) {
                        return "预约试纱";
                    }
                    return "预约看店";
            }
        }
    }
}
{% endhighlight %}

{% highlight java %}
// 20141222 过滤旅游婚纱的分类
List<Integer> ignoreProductCategoryIds = new ArrayList<Integer>();
ignoreProductCategoryIds.add(Constants.PCATE_TRAVELWED);

PageModel pagemodel = weddingShopProductService.paginateShopProductsByShopIdAndCategoryFilter(page, limit, shop.getShopId(), null, ignoreProductCategoryIds, WeddingShopProductOrderEnum.UPDATE_DESC);
// 相信你看到这段代码的时候, 已经心中无数草泥马在奔腾....BUT...
// 这里还没有结束, 因为这个筛选结果是排除了旅游婚纱的结果, 但是总数却需要返回包含旅游婚纱的数据.
// 这个逻辑以后直接找产品去, 我也不知道怎么维护, 如果你看到了这个代码, 千万别骂我, 我也他妈的没办法.
// 现在只有我和上帝能看懂这段逻辑, 等你看的时候, 估计只有上帝能看懂了.
// God bless you.
PageModel result = weddingShopProductService.paginateShopProductsByShopIdAndCategoryFilter(page, limit, shop.getShopId(), null, null, WeddingShopProductOrderEnum.UPDATE_DESC);
if (result == null) {
    return null;
} else {
    result.setRecords(pagemodel.getRecords());
    return result;
}
{% endhighlight %}

{% highlight java %}
// 收集所有推荐的产品id, 这个productIds 也就是输出的排序
List<Integer> productIds = new LinkedList<Integer>();
for (List<ShopProductRecommendDTO> values : recommendShopProducts.values()) {
    for (ShopProductRecommendDTO value : values) {
        if (productIds.size() < limit && value.getIsUseful()) {
            // 20141222 这里要过滤掉所有的旅游婚纱的分类!! 我操我操 fuckfuckfuck, 这个代码以后谁tm来维护!
            if (value.getProductCategoryId() == Constants.PCATE_TRAVELWED) {
                continue;
            }
            productIds.add(value.getProductId());
        }
    }
}
{% endhighlight %}

{% highlight java %}
boolean isHomeDecorate = HomeUtil.isHomeDecorate(shop.getMainCategoryId()) && VersionUtil.compare(context.getVersion(), "6.9.5") >= 0;
for (WeddingShopProductDTO dto : productDtos) {
    if(isHomeDecorate){
        //家装的装修设计分类，需要有version的判断
        List<Map<String,Object>> tags = weddingShopProductService.findAllTagsByProductId(dto.getId());
        productDos.add(new WeddingProductDo(dto, coverPicType, tags, context));
    }
    else{
        productDos.add(new WeddingProductDo(dto, coverPicType));
    }
}
{% endhighlight %}

规则引擎的出现非常好的解决了这样将一些复杂的条件判断耦合在业务代码中的难以维护的问题. 通过一组规则(版本/分类/标签等), 为接口的返回提供了一套预判的配置, 比如"最多输出几个? 最少输出几个? 忽略哪几个? 默认是啥?", 那么接口在处理业务逻辑的时候, 完全可以只通过这个配置处理, 将复杂的判断抽离统一的业务逻辑.

## 如何使用

1. 使用eclipse或者idea作为IDE的同学可以去直接下载drools的插件. 官方的库里就有
2. 对于本地要启动mobileapi项目的, 需要在本地的 `%TOMCAT_HOME%/bin/catalian.sh` 中加入这么一行代码, 放心加, 这个是生产环境上也有的.

{% highlight bash %}
CATALINA_OPTS="$CATALINA_OPTS -Dclient.encoding.override=UTF-8 -Dfile.encoding=UTF-8 -Duser.language=zh -Duser.region=CN"
{% endhighlight %}

3. 参考 **之前写的规则**, 添加自己新的规则.

4. 通过 **单元测试**, 来验证自己的规则已经生效, 并且符合预期.

**举个例子**

这个需求是: 针对7.2.0版本的客户端及以上版本, 如果商户分类是亲子购物或者亲子游乐, 则显示4个团购推荐, 这4个推荐必须是亲子游乐/幼儿教育/亲子摄影分类的. 如果搜索到的团购不足2个, 则隐藏该模块, 是不是很绕?

于是我们创建一个用于配置的Fact对象:

{% highlight java %}
public class GrouponRecommendConfigFT {

    /** 是否需要推荐团购 */
    private boolean needRecommend;

    private int maxLimit;
    private int minLimit;

    private List<Integer> shopCategoryIdList = Lists.newLinkedList();

    public void addShopCategoryId(int categoryId) {
        this.shopCategoryIdList.add(categoryId);
    }
}
{% endhighlight %}

并正对这个业务去定制规则:

{% highlight java %}
declare BabyFunAndShopping
end

rule "默认不输出团购推荐"
    salience 1000

    lock-on-active true

    when
        $config: GrouponRecommendConfigFT()
    then
        $config.setNeedRecommend(false);

end

rule "判断是否为亲子游乐或亲子购物"
    salience 999

    lock-on-active true

    when
        Category(id == Constants.CATE_BABY_SHOPPING || id == Constants.CATE_BABY_FUN)
    then
        insert(new BabyFunAndShopping());

end

rule "只输出两个推荐"
    salience 998

    no-loop true

    when
        $config: GrouponRecommendConfigFT()
        IMobileContext(VersionUtil.compare(version, "7.2.0") >= 0)
        BabyFunAndShopping()
    then
        $config.setNeedRecommend(true);
        $config.setMinLimit(2);
        $config.setMaxLimit(4);
        $config.addShopCategoryId(Constants.CATE_BABY_EDU);
        $config.addShopCategoryId(Constants.CATE_BABY_FUN);
        $config.addShopCategoryId(Constants.CATE_BABY_PHOTO);

end
{% endhighlight %}

可以看到, 我们只是针对业务, 去生成一个最终的配置, 最终的接口逻辑就是根据这份配置去做最终的输出.

下面针对这个业务, 定制我们的单元测试来验证规则:

{% highlight java %}
@Test
public void testBabyShopping7_2_0() {
    ShopDTO shop = new ShopDTO();

    Category category = new Category();
    category.setId(Constants.CATE_BABY_SHOPPING);

    MobileContext context = new MobileContext();
    context.setVersion("7.2.0");

    IRuleProcessor ruleProcessor = ruleEngine.getProcessor(Processor.BABY_GROUPON_RECOMMEND);

    List<Object> facts = new ArrayList<Object>();
    facts.add(shop);
    facts.add(category);
    facts.add(context);

    GrouponRecommendConfigFT configFT = (GrouponRecommendConfigFT) ruleProcessor.execute(facts);
    assertTrue(configFT.isNeedRecommend());
    assertEquals(4, configFT.getMaxLimit());
    assertEquals(2, configFT.getMinLimit());
    assertTrue(configFT.getShopCategoryIdList().contains(Constants.CATE_BABY_EDU));
    assertTrue(configFT.getShopCategoryIdList().contains(Constants.CATE_BABY_PHOTO));
    assertTrue(configFT.getShopCategoryIdList().contains(Constants.CATE_BABY_FUN));

}
{% endhighlight %}

## 下一步的设想

1. 可以通过一个web去动态的修改规则实现规则的动态调整, 而不用停机发布, 可以将规则保存在zookeeper, 或者通过swallow的方式发送给所有的web server. 这一点drools框架是支持的.

2. 在一些适合的场景也引入规则引擎, 如发红包活动, 防作弊点赞等.

## 常见问题

1. 既然drools可以动态加载, 和groovy有点类似, 为啥不直接用groovy? 

groovy虽然可以动态加载, 但实际上还是要在里面写一大堆if...else逻辑, 等于是把恶心的逻辑放到了另一个文件, 并没有实现解耦. 而规则引擎更像是邮件的fillter, 配置更灵活. 另一个很重要的原因是, drools 在compile rules的时候, 会通过 [RETE](http://www.paper.edu.cn/download/downPaper/200812-814) 算法进行优化, 效率更高.

2. 为啥不直接用lion?

还嫌lion不够乱的? 每个api加2个配置, 维护都是一场灾难.

3. 性能怎样?

前面说到了drools在 [RETE](http://www.paper.edu.cn/download/downPaper/200812-814) 的算法的基础上还做了一写自己的优化, 性能绝对不是问题. 在之前的公司, 使用 drools 做风控判断. 针对3到5各rule, 2000+的qps轻轻松松.

#### 参考文档
* 官方文档 [https://docs.jboss.org/drools/release/5.6.0.Final/drools-docs/html_single](https://docs.jboss.org/drools/release/5.6.0.Final/drools-docs/html_single)
* RETE算法 [http://www.paper.edu.cn/download/downPaper/200812-814](http://www.paper.edu.cn/download/downPaper/200812-814) 