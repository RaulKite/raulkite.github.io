---
layout: post
title: Dockerized Jenkins with https
date: 2016-10-01
category: docker
tags: docker jenkins 
image: /assets/article_images/2016-10-01-Dockerized-Jenkins/banner.jpg
---

Trying to execute jenkins with docker to run my tests and build automated docker images of my services I have had an awkward issue. Https is not working with the official jenkins image.
The problem seems to be a bug using Java 8. So the only way I have found to solve it has been to create an intermediate jenkins image importing form java7.

So I clone the official jenkins image and generate a new one importing from java7.

{% highlight bash %}

$ git clone https://github.com/jenkinsci/docker.git
$ cd jenkinsci
$ sed -i 's/openjdk:8-jdk/openjdk:7-jdk/g' Dockerfile
$ docker docker build -t raulkite/jenkins:conjava7 .

{% endhighlight %}

Once that I have built the new jenkins base image, I use it to install docker inside. This way:

First, we have to create the keystore:

{% highlight bash %}
$ letsencrypt certonly --standalone -d ci.stackvdi.com
$ cp /etc/letsencrypt/live/ci.stackvdi.com/cert.pem ssl/ci.stackvdi.com.crt
$ cp /etc/letsencrypt/live/ci.stackvdi.com/privkey.pem ci.stackvdi.com.key


$ openssl pkcs12 -inkey ci.stackvdi.com.key -in ci.stackvdi.com.crt -export -out ci.stackvdi.com.pkcs12
$ keytool -importkeystore -srckeystore ci.stackvdi.com.pkcs12 -srcstoretype pkcs12 -destkeystore keystore
{% endhighlight %}

and then the Dockerfile:

{% highlight bash %}
FROM raulkite/jenkins:conjava7

USER root

RUN echo "deb http://apt.dockerproject.org/repo debian-jessie main"  > /etc/apt/sources.list.d/docker.list \
  && apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
  && apt-get update \
  && apt-get install -y apt-transport-https \
  && apt-get install -y sudo \
  && apt-get install -y docker-engine \
  && apt-get install -y jq \
  && rm -rf /var/lib/apt/lists/*

RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers

RUN curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose

COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

USER jenkins

COPY keystore /var/lib/jenkins/keystore

ENV JENKINS_OPTS --httpPort=8080 --httpsPort=8443 --httpsKeyStore=/var/lib/jenkins/keystore --httpsKeyStorePassword=cambiame

EXPOSE 8443
{% endhighlight %}

We create the new jenkins image and launch it:

{% highlight bash %}
$ docker build -t raulkite/jenkins_dockerizado .
$ sudo docker run -d --name jenkins -p 8443:8443 -p 50000:50000 -v /srv/jenkins/:/var/jenkins_home raulkite/jenkins_dockerizado
{% endhighlight %}

And ... voila!

![Screenshot](/assets/article_images/2016-10-01-Dockerized-Jenkins/screenshot.png)
