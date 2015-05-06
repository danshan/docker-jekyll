---
layout: post
title: 使用 javamail 发送 SSL 加密邮件
date: 2013-02-10 20:37
description: "使用javamail发送邮件, 同时解决 SSL 证书问题. 用以实现服务器直接给用户发送邮件功能"
category: Tech
tags: [java, mail, ssl]
---
在实现一个用户 passport 系统或者其他大型系统的时候, 常常需要使用给用户发送邮件的功能, 下面介绍整套解决方案.

* 添加项目依赖

在 maven 配置文件 pom.xml 中添加如下依赖:

{% highlight xml %}
<dependency>
  <groupId>javax.mail</groupId>
  <artifactId>mail</artifactId>
  <version>1.4.5</version>
</dependency>
{% endhighlight %}

* 实现邮件发送类

实现发送邮件功能的代码如下:

{% highlight java %}
package com.vipshop.passport.mail;

import java.security.Security;
import java.util.Date;
import java.util.Properties;

import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;


/**
 * 发送邮件模块
 * @author dan.shan
 *
 */
public class JavaMailSslSender {

    private static Properties serverProps;
    
    private static final String SSL_FACTORY = "javax.net.ssl.SSLSocketFactory";
    private static final String SMTP_HOST = "smtp.server.com"; // smtp 服务器地址
    private static final int SMTP_PORT = 465; // smtp 服务器端口
    
    private static final String FROM_ADDR = "dan.shan@mail.com"; // 邮件的发送者地址
    private static final String USERNAME = "username"; // 用户名
    private static final String PASSWORD = "password"; // 密码
    
    static {
        serverProps = new Properties();
        serverProps.setProperty("mail.smtp.host", SMTP_HOST);
        serverProps.setProperty("mail.smtp.socketFactory.class", SSL_FACTORY);
        serverProps.setProperty("mail.smtp.socketFactory.fallback", "false");
        serverProps.setProperty("mail.smtp.port", String.valueOf(SMTP_PORT));
        serverProps.setProperty("mail.smtp.socketFactory.port", String.valueOf(SMTP_PORT));
        serverProps.put("mail.smtp.auth", "true");
    }
    
    private void send(String receiver, String subject, String content) throws AddressException, MessagingException {
        Security.addProvider(new com.sun.net.ssl.internal.ssl.Provider());
        Session session = Session.getDefaultInstance(serverProps, new Authenticator() {

                @Override
                protected PasswordAuthentication getPasswordAuthentication() {
                    return new PasswordAuthentication(USERNAME, PASSWORD);
                }
        });
        
        Message msg = new MimeMessage(session);
        msg.setFrom(new InternetAddress(FROM_ADDR));
        msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse(receiver, false));
        msg.setSubject(subject);
        msg.setText(content);
        msg.setSentDate(new Date());
        Transport.send(msg);

        System.out.println("Message sent.");
    }
    
    public static void main(String[] args) throws AddressException, MessagingException {
        new JavaMailSslSender().send("ad@shanhh.com", "hello", "test");
    }
    
}
{% endhighlight %}

* 导入证书文件

这里使用的 SSL 邮件加密的方案, 但是有时会抛出如下的异常, 通常也发生在第一次调用发送功能的时候:

{% highlight bash %}
Exception in thread "main" javax.mail.MessagingException: Could not connect to SMTP host: smtp.server.com, port: 465;
  nested exception is:
    javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
    at com.sun.mail.smtp.SMTPTransport.openServer(SMTPTransport.java:1972)
    at com.sun.mail.smtp.SMTPTransport.protocolConnect(SMTPTransport.java:642)
    at javax.mail.Service.connect(Service.java:317)
    at javax.mail.Service.connect(Service.java:176)
    at javax.mail.Service.connect(Service.java:125)
    at javax.mail.Transport.send0(Transport.java:194)
    at javax.mail.Transport.send(Transport.java:124)
    at com.vipshop.passport.mail.JavaMailSslSender.send(JavaMailSslSender.java:64)
    at com.vipshop.passport.mail.JavaMailSslSender.main(JavaMailSslSender.java:70)
Caused by: javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
    at com.sun.net.ssl.internal.ssl.Alerts.getSSLException(Alerts.java:174)
    at com.sun.net.ssl.internal.ssl.SSLSocketImpl.fatal(SSLSocketImpl.java:1764)
    at com.sun.net.ssl.internal.ssl.Handshaker.fatalSE(Handshaker.java:241)
    at com.sun.net.ssl.internal.ssl.Handshaker.fatalSE(Handshaker.java:235)
    at com.sun.net.ssl.internal.ssl.ClientHandshaker.serverCertificate(ClientHandshaker.java:1206)
    at com.sun.net.ssl.internal.ssl.ClientHandshaker.processMessage(ClientHandshaker.java:136)
    at com.sun.net.ssl.internal.ssl.Handshaker.processLoop(Handshaker.java:593)
    at com.sun.net.ssl.internal.ssl.Handshaker.process_record(Handshaker.java:529)
    at com.sun.net.ssl.internal.ssl.SSLSocketImpl.readRecord(SSLSocketImpl.java:958)
    at com.sun.net.ssl.internal.ssl.SSLSocketImpl.performInitialHandshake(SSLSocketImpl.java:1203)
    at com.sun.net.ssl.internal.ssl.SSLSocketImpl.startHandshake(SSLSocketImpl.java:1230)
    at com.sun.net.ssl.internal.ssl.SSLSocketImpl.startHandshake(SSLSocketImpl.java:1214)
    at com.sun.mail.util.SocketFetcher.configureSSLSocket(SocketFetcher.java:548)
    at com.sun.mail.util.SocketFetcher.createSocket(SocketFetcher.java:352)
    at com.sun.mail.util.SocketFetcher.getSocket(SocketFetcher.java:207)
    at com.sun.mail.smtp.SMTPTransport.openServer(SMTPTransport.java:1938)
    ... 8 more
Caused by: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
    at sun.security.validator.PKIXValidator.doBuild(PKIXValidator.java:323)
    at sun.security.validator.PKIXValidator.engineValidate(PKIXValidator.java:217)
    at sun.security.validator.Validator.validate(Validator.java:218)
    at com.sun.net.ssl.internal.ssl.X509TrustManagerImpl.validate(X509TrustManagerImpl.java:126)
    at com.sun.net.ssl.internal.ssl.X509TrustManagerImpl.checkServerTrusted(X509TrustManagerImpl.java:209)
    at com.sun.net.ssl.internal.ssl.X509TrustManagerImpl.checkServerTrusted(X509TrustManagerImpl.java:249)
    at com.sun.net.ssl.internal.ssl.ClientHandshaker.serverCertificate(ClientHandshaker.java:1185)
    ... 19 more
Caused by: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
    at sun.security.provider.certpath.SunCertPathBuilder.engineBuild(SunCertPathBuilder.java:174)
    at java.security.cert.CertPathBuilder.build(CertPathBuilder.java:238)
    at sun.security.validator.PKIXValidator.doBuild(PKIXValidator.java:318)
    ... 25 more
{% endhighlight %}

网上查了一些资料, 一般都是由于 SSL 证书找不到引起的异常, 我们需要给 JRE 导入 smtp 服务器的证书文件.

下面我们来实现一个证书的下载类:

{% highlight java %}
package com.vipshop.passport.mail;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.security.KeyStore;
import java.security.MessageDigest;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;

import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLException;
import javax.net.ssl.SSLSocket;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.TrustManagerFactory;
import javax.net.ssl.X509TrustManager;

/**
 * 下载证书功能
 * 
 * @author dan.shan
 * 
 */
public class InstallCert {

    private static final String CERT_FILE = "smtp.server.cert";
    
    public static void main(String[] args) throws Exception {
        
        String host; // 服务器地址
        int port; // 服务器端口, 默认443
        char[] passphrase;
        
        if ((args.length == 1) || (args.length == 2)) {
            String[] c = args[0].split(":");
            host = c[0];
            port = (c.length == 1) ? 443 : Integer.parseInt(c[1]);
            String p = (args.length == 1) ? "changeit" : args[1];
            passphrase = p.toCharArray();
        } else {
            System.out.println("Usage: java InstallCert <host>[:port] [passphrase]");
            return;
        }

        File file = new File(CERT_FILE);
        if (file.isFile() == false) {
            char SEP = File.separatorChar;
            File dir = new File(System.getProperty("java.home")
                    + SEP + "lib" + SEP + "security");
            file = new File(dir, CERT_FILE);
            if (file.isFile() == false) {
                file = new File(dir, "cacerts");
            }
        }
        System.out.println("Loading KeyStore " + file + "...");
        InputStream in = new FileInputStream(file);
        KeyStore ks = KeyStore.getInstance(KeyStore.getDefaultType());
        ks.load(in, passphrase);
        in.close();

        SSLContext context = SSLContext.getInstance("TLS");
        TrustManagerFactory tmf =
                TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        tmf.init(ks);
        X509TrustManager defaultTrustManager =
                (X509TrustManager) tmf.getTrustManagers()[0];
        SavingTrustManager tm = new SavingTrustManager(defaultTrustManager);
        context.init(null, new TrustManager[] { tm }, null);
        SSLSocketFactory factory = context.getSocketFactory();

        System.out.println("Opening connection to " + host + ":" + port + "...");
        SSLSocket socket = (SSLSocket) factory.createSocket(host, port);
        socket.setSoTimeout(10000);
        try {
            System.out.println("Starting SSL handshake...");
            socket.startHandshake();
            socket.close();
            System.out.println("No errors, certificate is already trusted");
        } catch (SSLException e) {
            System.out.println("Certificate has not been trusted");
        }

        X509Certificate[] chain = tm.chain;
        if (chain == null) {
            System.out.println("Could not obtain server certificate chain");
            return;
        }

        BufferedReader reader =
                new BufferedReader(new InputStreamReader(System.in));

        System.out.println();
        System.out.println("Server sent " + chain.length + " certificate(s):");
        System.out.println();
        MessageDigest sha1 = MessageDigest.getInstance("SHA1");
        MessageDigest md5 = MessageDigest.getInstance("MD5");
        for (int i = 0; i < chain.length; i++) {
            X509Certificate cert = chain[i];
            System.out.println(" " + (i + 1) + " Subject " + cert.getSubjectDN());
            System.out.println("   Issuer  " + cert.getIssuerDN());
            sha1.update(cert.getEncoded());
            System.out.println("   sha1    " + toHexString(sha1.digest()));
            md5.update(cert.getEncoded());
            System.out.println("   md5     " + toHexString(md5.digest()));
            System.out.println();
        }

        System.out.println("Enter certificate to add to trusted keystore or 'q' to quit: [1]");
        String line = reader.readLine().trim();
        int k;
        try {
            k = (line.length() == 0) ? 0 : Integer.parseInt(line) - 1;
        } catch (NumberFormatException e) {
            System.out.println("KeyStore not changed");
            return;
        }

        X509Certificate cert = chain[k];
        String alias = host + "-" + (k + 1);
        ks.setCertificateEntry(alias, cert);

        OutputStream out = new FileOutputStream("jssecacerts");
        ks.store(out, passphrase);
        out.close();

        System.out.println();
        System.out.println(cert);
        System.out.println();
        System.out.println("Added certificate to keystore 'jssecacerts' using alias '" + alias + "'");
    }

    private static final char[] HEXDIGITS = "0123456789abcdef".toCharArray();

    private static String toHexString(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 3);
        for (int b : bytes) {
            b &= 0xff;
            sb.append(HEXDIGITS[b >> 4]);
            sb.append(HEXDIGITS[b & 15]);
            sb.append(' ');
        }
        return sb.toString();
    }

    private static class SavingTrustManager implements X509TrustManager {

        private final X509TrustManager tm;
        private X509Certificate[] chain;

        SavingTrustManager(X509TrustManager tm) {
            this.tm = tm;
        }

        @Override
        public X509Certificate[] getAcceptedIssuers() {
            throw new UnsupportedOperationException();
        }

        @Override
        public void checkClientTrusted(X509Certificate[] chain, String authType)
                throws CertificateException {
            throw new UnsupportedOperationException();
        }

        @Override
        public void checkServerTrusted(X509Certificate[] chain, String authType)
                throws CertificateException {
            this.chain = chain;
            tm.checkServerTrusted(chain, authType);
        }
    }

}
{% endhighlight %}

我们直接执行这个类:

    java package com.vipshop.passport.mail.InstallCert smtp.server.com:465

将直接显示可下载的证书:

{% highlight bash %}
Loading KeyStore /home/dan/tools/jdk1.6.0_35/jre/lib/security/cacerts...
Opening connection to smtp.servercom:465...
Starting SSL handshake...
Certificate has not been trusted

Server sent 1 certificate(s):

 1 Subject CN=demo.coremail.cn, OU=Coremail, O=Mailtech, L=GuangZhou, ST=GuangDong, C=CN
   Issuer  CN=ca.mailtech.cn, OU=CA, O=Mailtech, L=GuangZhou, ST=GuangDong, C=CN
   sha1    32 ac 92 0f 95 44 90 b8 26 05 b2 fc 9a 91 38 ff ba 33 18 e2 
   md5     83 59 8d fd 1a fe dc 57 ff 5c 7a ba c9 50 68 b0 

Enter certificate to add to trusted keystore or 'q' to quit: [1]
{% endhighlight %}

输入`1`并回车后会将证书下载到当前文件夹中的**smtp.server.cert**. 之后将这个文件放到**$JAVA_HOME/jre/lib/security**, 重新执行发送的程序, 已经可以正常发送了.
