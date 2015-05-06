---
layout: post
title: 实现在单元测试中验证 memcached 服务 
date: 2013-02-11 18:27
description: "在实现一个服务器项目时, 使用了 memcache 服务, 下面需要在 junit 单元测试中实现对 memcache 服务的验证工作"
category: Tech
tags: [junit, java, memcached]
---
在实现一个服务器项目时, 使用了 memcached 服务, 下面需要在 junit 单元测试中实现对 memcache 服务的验证工作.

为了能让 junit 能在不依赖测试环境的情况下执行, 所以不应该需要测试环境中搭建 memcached 才能执行测试. 所以解决方案一般有两种:

* 试用 mock 完整测试的桩
* 在执行测试的时候, 本地启动一个轻量级的 memcached 服务端

本文使用的是第二种方案, 下面介绍详细的实现过程.

[jmemcached](http://code.google.com/p/jmemcache-daemon/) 是一个 Java 版的 [memcached](http://memcached.org/) 缓存服务器, 基本上跟 memcached 是兼容的. jmemcached 是使用 [Apache MINA](http://mina.apache.org/) 作为无堵塞的网络IO操作, 但从 0.7 版本开始 jmemcached 改用了 [Netty](http://jshonk.com) 作为网络IO操作包.

我这里直接对 xmemcached 作为 memcached 客户端, 我在外面做了一层包装:

{% highlight java %}
package com.vipshop.passport.util;

import javax.annotation.Resource;

import net.rubyeye.xmemcached.MemcachedClient;

import com.vipshop.passport.common.Logger;
import com.vipshop.passport.config.FileConfig;

/**
 * @author dan.shan
 *
 */
public class MemcachedUtils {
    
    private static final Logger logger = Logger.getLogger(MemcachedUtils.class);
    
    @Resource
    private MemcachedClient memcachedClient;
    
    /**
     * 保存value, 永不超时
     * @param key
     * @param value
     */
    public void put(String key, Object value) {
        this.put(key, value, 0);
    }

    /**
     * 保存value, 过期超时
     * @param key
     * @param value
     * @param exp 超时时间, second
     */
    public void put(String key, Object value, int exp) {
        long start = System.currentTimeMillis();
        if (FileConfig.isMemcacheEnable()) { return; }
        try {
            memcachedClient.set(key, exp, value);
        } catch (Exception e) {
            logger.error("put memcache value error, key={0}", e, key);
        }
        long end = System.currentTimeMillis();
        logger.info("put memcache value, key={0}, use {1}ms", key, end - start);
    }

    /**
     * remove value by key
     * @param key
     */
    public void delete(String key) {
        long start = System.currentTimeMillis();
        if (FileConfig.isMemcacheEnable()) { return; }
        
        try {
            memcachedClient.delete(key);
        } catch (Exception e) {
            logger.error("delete memcache value error, key={0}", e, key);
        }
        long end = System.currentTimeMillis();
        logger.info("delete memcache value, key={0}, use {1}ms", key, end - start);
    }

    /**
     * get value by key
     * @param key
     * @return
     */
    public Object get(String key) {
        long start = System.currentTimeMillis();
        if (FileConfig.isMemcacheEnable()) { return null; }
        
        Object value;
        try {
            value = memcachedClient.get(key);
        } catch (Exception e) {
            logger.error("get memcache value error, key={0}", e, key);
            value = null;
        }
        long end = System.currentTimeMillis();
        logger.info("get memcache value, key={0}, use {1}ms", key, end - start);
        
        return value;
    }

    /** @param memcachedClient the memcachedClient to set */
    public void setMemcachedClient(MemcachedClient memcachedClient) {
        this.memcachedClient = memcachedClient;
    }
    
}
{% endhighlight %}

实现单元测试的代码就相对简单多了:

{% highlight java %}
package com.vipshop.passport.util;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

import java.net.InetSocketAddress;
import java.util.UUID;

import net.rubyeye.xmemcached.MemcachedClient;

import org.junit.BeforeClass;
import org.junit.Test;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

import com.thimbleware.jmemcached.CacheImpl;
import com.thimbleware.jmemcached.Key;
import com.thimbleware.jmemcached.LocalCacheElement;
import com.thimbleware.jmemcached.MemCacheDaemon;
import com.thimbleware.jmemcached.storage.CacheStorage;
import com.thimbleware.jmemcached.storage.hash.ConcurrentLinkedHashMap;

/**
 * @author dan.shan
 *
 */
public class MemcachedUtilsTest {

    private static MemcachedUtils mcUtils;
    
    /**
     * @throws java.lang.Exception
     */
    @BeforeClass
    public static void setUp() throws Exception {
        MemCacheDaemon<LocalCacheElement> daemon = new MemCacheDaemon<LocalCacheElement>();

        // 这里启动一个本地的 memcached 服务器端
        CacheStorage<Key, LocalCacheElement> storage = ConcurrentLinkedHashMap.create(ConcurrentLinkedHashMap.EvictionPolicy.FIFO, 100, 2048);
        daemon.setCache(new CacheImpl(storage));
        daemon.setBinary(false);
        daemon.setAddr(new InetSocketAddress("127.0.0.1", 11211));
        daemon.setIdleTime(1024);
        daemon.setVerbose(false);
        daemon.start();
        
        ApplicationContext context = new ClassPathXmlApplicationContext("classpath:spring/applicationContext.xml");
        MemcachedClient client = (MemcachedClient) context.getBean("memcachedClient");
        mcUtils = new MemcachedUtils();
        mcUtils.setMemcachedClient(client);
    }

    @Test
    public void testPut() throws InterruptedException {
        
        String key = UUID.randomUUID().toString();
        String value = UUID.randomUUID().toString();
        
        assertNull(mcUtils.get(key));
        
        mcUtils.put(key, value, 3);
        assertEquals(value, (String) mcUtils.get(key));
        
        Thread.sleep(4000);
        
        assertNull(mcUtils.get(key));
    }
    
    @Test
    public void testDelete() {
        String key = UUID.randomUUID().toString();
        String value = UUID.randomUUID().toString();
        
        mcUtils.put(key, value);
        assertEquals(value, (String) mcUtils.get(key));
        
        mcUtils.delete(key);
        assertNull(mcUtils.get(key));
        
    }

}
{% endhighlight %}
