# redis-docker

## マスタースレーブ構成

### マスター

```
requirepass <password>
```

### スレーブ

```
slaveof localhost 6379
masterauth <password>
```


## Redis Cluster

以下記載のport番号はデフォルト値

  * clientとの通信用の **6379** の他に node間のp2p通信用の **16379** を解放する必要がある
  * Docker Containerでの利用の場合は *network mode* を **host** に設定する必要がある
     * node間通信はホストのNATで実現するため
     * もしかして、 **privileged** オプションも必要?? (要検証)

### Clusterの構成

  * https://github.com/projecteru/redis-trib.py

#### 1. マルチマスタ

#### 2. マスタ-スレーブ




