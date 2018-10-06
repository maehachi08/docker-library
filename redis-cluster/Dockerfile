#
#  Description:
#
#
#  Build:
#
#      docker build -t maehachi08/redis ./
#
FROM amazonlinux:2018.03
LABEL maintainer="maehachi08"

WORKDIR /opt
COPY . .

RUN set -x \

  && yum install -y epel-release \
  && yum install -y --enablerepo=epel redis ruby24 \
  && gem install redis \
  && curl -o /usr/bin/redis-trib.rb http://download.redis.io/redis-stable/src/redis-trib.rb \
  && chmod 755 /usr/bin/redis-trib.rb \
  && mkdir -p /usr/local/redis \
  && cp /etc/redis.conf /usr/local/redis/single_node.conf \
  && chmod +x /opt/init.sh

CMD ["/opt/init.sh"]

