#!/bin/bash
set -ue

# Redis Cluster requires at least 3 master nodes.
CLUSTER_MASTER_COUNT=${CLUSTER_MASTER_COUNT:-3}
CLUSTER_START_PORT=${CLUSTER_START_PORT:-7000}

m_servers=""
s_servers=""
count=1
master_port=${CLUSTER_START_PORT}
slave_port=$((${master_port} + 1))

while [ ${CLUSTER_MASTER_COUNT} -ge ${count} ]; do

  echo "Generate conifg..."
  echo "  redis cluster master node(${master_port}/TCP): /usr/local/redis/redis_cluster_${master_port}.conf"
  echo "  redis cluster slave node(${slave_port}/TCP)  : /usr/local/redis/redis_cluster_${slave_port}.conf"
  for port in ${master_port} ${slave_port}; do
    cat /usr/local/redis/single_node.conf \
      | sed -e 's/^port.*/port '$port'/' \
      | sed -e 's/^appendonly.*/appendonly yes/' \
      | sed -e 's/^#\scluster-enabled.*/cluster-enabled yes/' \
      | sed -e 's/^#\scluster-config-file.*/cluster-config-file nodes-'$port'.conf/' \
      | sed -e 's/^# cluster-node-timeout.*/cluster-node-timeout 15000/' \
      > /usr/local/redis/redis_cluster_${port}.conf
  done

  echo "Start redis-server..."
  echo "  redis cluster master node(${master_port}/TCP)"
  redis-server /usr/local/redis/redis_cluster_${master_port}.conf &
  echo "  redis cluster slave node(${slave_port}/TCP)"
  redis-server /usr/local/redis/redis_cluster_${slave_port}.conf &

  echo -e "done!!!\n"
  m_servers="${m_servers} 127.0.0.1:${master_port}"
  s_servers="${s_servers} 127.0.0.1:${slave_port}"
  master_port=$((master_port += 2))
  slave_port=$((slave_port += 2))
  count=$((count += 1))
done

echo "Create redis cluster..."
echo "  redis cluster master node"
yes "yes" | /usr/bin/redis-trib.rb create ${m_servers}

echo "  redis cluster slave node"
count=1
master_port=${CLUSTER_START_PORT}
while [ ${CLUSTER_MASTER_COUNT} -ge ${count} ]; do
  master_id=`redis-cli -p ${master_port} cluster nodes | grep myself | awk '{print $1}'`
  yes "yes" | /usr/bin/redis-trib.rb add-node --slave --master-id ${master_id} 127.0.0.1:$(( ${master_port} + 1 )) 127.0.0.1:${master_port}
  master_port=$((master_port += 2))
  count=$((count += 1))
done

tail -f /var/log/redis/redis.log
