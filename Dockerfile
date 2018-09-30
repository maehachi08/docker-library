FROM centos:latest

COPY docker-entrypoint.sh /usr/local/bin/

# Setup gosu for easier command execution
ENV GOSU_VERSION="1.7"
ENV GOSU_DOWNLOAD_ROOT="https://github.com/tianon/gosu/releases/download/$GOSU_VERSION"
ENV GOSU_DOWNLOAD_KEY="0x036A9C25BF357DD4"
RUN set -ex \
    && gpg --keyserver pool.sks-keyservers.net --recv-keys $GOSU_DOWNLOAD_KEY \
    && curl -o /usr/local/bin/gosu -SL "$GOSU_DOWNLOAD_ROOT/gosu-amd64" \
    && curl -o /usr/local/bin/gosu.asc -SL "$GOSU_DOWNLOAD_ROOT/gosu-amd64.asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && rm -r /root/.gnupg/ \
    && chmod +x /usr/local/bin/gosu

# Setup mysql
RUN set -ex \
    && yum localinstall -y http://dev.mysql.com/get/mysql57-community-release-el7-7.noarch.rpm \
    && rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-mysql \
    && yum install -y mysql \
                      mysql-devel \
                      mysql-server \
                      # for mysql_ssl_rsa_setup
                      openssl \
    && test -e /var/lib/mysql && rm -rf /var/lib/mysql \
    && mkdir -p /var/lib/mysql /var/run/mysqld \
    && mkdir /docker-entrypoint-initdb.d \
    && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
    && chmod +x /usr/local/bin/docker-entrypoint.sh \
    && ln -s /usr/local/bin/docker-entrypoint.sh /entrypoint.sh # backwards compat

VOLUME /var/lib/mysql
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

EXPOSE 3306 33060
CMD ["mysqld"]

