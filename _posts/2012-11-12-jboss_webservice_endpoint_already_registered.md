---
layout: post
title: 解决Jboss报出 URL pattern /Coordinator is already registered 错误
date: 2012-11-12 13:35
description: "部分web项目在jboss7.0.x工作正常, 但是迁移到7.1的时候报出**URL pattern /Coordinator is already registered**"
category: Tech
tags: [jboss, webservice]
---

部分web项目在jboss7.0.x工作正常, 但是迁移到7.1的时候报出**URL pattern /Coordinator is already registered**, 报错信息如下:

    10:22:06,097 ERROR [org.jboss.msc.service.fail] (MSC service thread 1-3) MSC00001: Failed to start service jboss.deployment.unit."snaLight.war".PARSE: org.jboss.msc.service.StartException in service jboss.deployment.unit."snaLight.war".PARSE: Failed to process phase PARSE of deployment "snaLight.war"
              at org.jboss.as.server.deployment.DeploymentUnitPhaseService.start(DeploymentUnitPhaseService.java:119) [jboss-as-server-7.1.0.Final.jar:7.1.0.Final]
              at org.jboss.msc.service.ServiceControllerImpl$StartTask.startService(ServiceControllerImpl.java:1811) [jboss-msc-1.0.2.GA.jar:1.0.2.GA]
              at org.jboss.msc.service.ServiceControllerImpl$StartTask.run(ServiceControllerImpl.java:1746) [jboss-msc-1.0.2.GA.jar:1.0.2.GA]
              at java.util.concurrent.ThreadPoolExecutor$Worker.runTask(ThreadPoolExecutor.java:886) [rt.jar:1.6.0_27]
              at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:908) [rt.jar:1.6.0_27]
              at java.lang.Thread.run(Thread.java:662) [rt.jar:1.6.0_27]
    Caused by: java.lang.IllegalArgumentException: JBAS015533: Web Service endpoint com.sun.xml.ws.tx.webservice.member.coord.ActivationRequesterPortTypeImpl with URL pattern /Coordinator is already registered. Web service endpoint com.sun.xml.ws.tx.webservice.member.coord.RegistrationRequesterPortTypeImpl is requesting the same URL pattern.
              at org.jboss.as.webservices.metadata.model.AbstractDeployment.addEndpoint(AbstractDeployment.java:60)
              at org.jboss.as.webservices.metadata.model.JAXWSDeployment.addEndpoint(JAXWSDeployment.java:27)
              at org.jboss.as.webservices.deployers.WSIntegrationProcessorJAXWS_POJO.processAnnotation(WSIntegrationProcessorJAXWS_POJO.java:94)
              at org.jboss.as.webservices.deployers.AbstractIntegrationProcessorJAXWS.deploy(AbstractIntegrationProcessorJAXWS.java:87)
              at org.jboss.as.server.deployment.DeploymentUnitPhaseService.start(DeploymentUnitPhaseService.java:113) [jboss-as-server-7.1.0.Final.jar:7.1.0.Final]
              ... 5 more
     
     
    10:22:06,112 INFO  [org.jboss.as.server] (DeploymentScanner-threads - 1) JBAS015870: Deploy of deployment "snaLight.war" was rolled back with failure message {"JBAS014671: Failed services" => {"jboss.deployment.unit.\"snaLight.war\".PARSE" => "org.jboss.msc.service.StartException in service jboss.deployment.unit.\"snaLight.war\".PARSE: Failed to process phase PARSE of deployment \"snaLight.war\""}}
    10:22:07,021 INFO  [org.jboss.as.server.deployment] (MSC service thread 1-3) JBAS015877: Stopped deployment snaLight.war in 884ms
    10:22:07,021 INFO  [org.jboss.as.controller] (DeploymentScanner-threads - 1) JBAS014774: Service status report
    JBAS014777:   Services which failed to start:      service jboss.deployment.unit."snaLight.war".PARSE: org.jboss.msc.service.StartException in service jboss.deployment.unit."snaLight.war".PARSE: Failed to process phase PARSE of deployment "snaLight.war"
     
    10:22:07,021 ERROR [org.jboss.as.server.deployment.scanner] (DeploymentScanner-threads - 2) {"JBAS014653: Composite operation failed and was rolled back. Steps that failed:" => {"Operation step-2" => {"JBAS014671: Failed services" => {"jboss.deployment.unit.\"snaLight.war\".PARSE" => "org.jboss.msc.service.StartException in service jboss.deployment.unit.\"snaLight.war\".PARSE: Failed to process phase PARSE of deployment \"snaLight.war\""}}}}

原因是, 从jboss7.1开始会启动一个自己的webservice 服务, 如果部署的项目中使用了webservice_rt.jar包, 就会导致冲突. 修改方法是禁用jboss的这个webservice服务.

打开`$JBOSS_HOME/standalone/configuration/standalone.xml`, 注释下面几行

{% highlight xml %}
<extension module="org.jboss.as.webservices"/>
{% endhighlight %}

{% highlight xml %} 
<subsystem xmlns="urn:jboss:domain:webservices:1.1">
    <modify-wsdl-address>true</modify-wsdl-address>
    <wsdl-host>${jboss.bind.address:127.0.0.1}</wsdl-host>
    <endpoint-config name="Standard-Endpoint-Config"/>
    <endpoint-config name="Recording-Endpoint-Config">
        <pre-handler-chain name="recording-handlers" protocol-bindings="##SOAP11_HTTP ##SOAP11_HTTP_MTOM ##SOAP12_HTTP ##SOAP12_HTTP_MTOM">
            <handler name="RecordingHandler" class="org.jboss.ws.common.invocation.RecordingServerHandler"/>
        </pre-handler-chain>
    </endpoint-config>
</subsystem>
{% endhighlight %}
