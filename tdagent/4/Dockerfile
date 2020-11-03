FROM amazonlinux:2

COPY files/etc/yum.repos.d//td.repo /etc/yum.repos.d//td.repo

RUN set -ex && \
  yum install -y vim less which hostname && \
  rpm --import https://packages.treasuredata.com/GPG-KEY-td-agent && \
  yum install -y td-agent && \
  /usr/sbin/td-agent-gem install fluent-plugin-forest && \
  yum clean all

COPY files/etc/td-agent/ /etc/td-agent/
