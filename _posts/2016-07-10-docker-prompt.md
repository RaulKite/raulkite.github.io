---
layout: post
title: Docker prompt in bash
date: 2016-07-10
category: docker
tags: docker 
image: /assets/article_images/2016-07-10-docker-prompt-in-bash/banner.jpg
---
Some days ago I saw an amazing [blat's](https://twitter.com/ferblape){:target="_blank"} [tweet](https://twitter.com/ferblape/status/735073552127365120){:target="_blank"}. His code changed your prompt advertising you if your `DOCKER_HOST` variable was set. I have made some "improvements" to differentiate connections to simple docker hosts and swarm clusters. 

Usually swarm cluster are listening in 4000 or 3376 port and docker engine in 2375 or 2376 port, so, that's what I use to check it.

This way you can advertise easily if you are pointing yout docker variables to a remote docker engine or swarm cluster.

{% highlight bash %}
# Parse DOCKER_HOST. Expecting this format: DOCKER_HOST="tcp://swarm-node-01.stackvdi.com:4000"
function __docker_prompt {
  if [ -n "$DOCKER_HOST" ]; then
    DOCKER_PORT=` echo "$DOCKER_HOST" | cut -d ':' -f3 `
    DOCKER_HOSTNAME=`echo $DOCKER_HOST | cut -d ':' -f2 | cut -d '/' -f3`
    # Si es una ip, la colocamos directamente, si no, cortamos el dominio
    if [[ $(echo $DOCKER_HOSTNAME | grep -v -E '((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)') ]]; then
         DOCKER_HOSTNAME=`echo $DOCKER_HOSTNAME | cut -d '.' -f1`
    fi
    if [ "$DOCKER_PORT" = "3376" ] || [ "$DOCKER_PORT" = "4000" ]; then
       ## Estamos conectados a un swarm cluster
       echo "(🐳🐳🐳 $DOCKER_HOSTNAME)"
    else
       echo "(🐳 $DOCKER_HOSTNAME)"
    fi
  fi
}

export CLICOLOR=1
export LSCOLORS='ExFxCxDxBxegedabagaced'
alias ls='ls --color'

function prompt {
  local BLACK="\[\033[0;30m\]"
  local RED="\[\033[0;31m\]"
  local GREEN="\[\033[0;32m\]"
  local YELLOW="\[\033[0;33m\]"
  local BLUE="\[\033[0;34m\]"
  local PURPLE="\[\033[0;35m\]"
  local CYAN="\[\033[0;36m\]"
  local WHITE="\[\033[0;37m\]"
  local WHITEBOLD="\[\033[1;37m\]"
  export PS1="\u@\h:${BLUE}\$(__docker_prompt)${WHITE}\w$ "
  export PS1="\[\033[G\]$PS1"
}

prompt

{% endhighlight %}

You can see how it looks like:

![Screenshot](/assets/article_images/2016-07-10-docker-prompt-in-bash/docker-prompt.png)
