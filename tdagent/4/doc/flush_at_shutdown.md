# flush_at_shutdown

## multiline でのshutdown動作について

* multiline におけるoutput pluginのshutdown処理がbefore_shutdownで呼び出される不具合については [修正済み](https://github.com/fluent/fluentd/pull/1763)
   * [lib/fluent/root_agent.rb#L265-L266](https://github.com/fluent/fluentd/blob/9ff9d79425b903cd1c16ce13c156b213ba47d5d7/lib/fluent/root_agent.rb#L265-L266)

### 検証

* `/var/log/ruby_on_rails.log` へログ追記後すぐにtd-agentにSIGINTシグナルを送信する
   1. stop
   2. before_shutdown(preparing shutdown)
      * `flush_at_shutdown` はここで処理される
         1. [before_shutdown](https://github.com/fluent/fluentd/blob/1c28d6ed0cf346c322fbca92bb4eafa65307c3eb/lib/fluent/plugin/output.rb#L490-L504)
         2. [force_flush](https://github.com/fluent/fluentd/blob/1c28d6ed0cf346c322fbca92bb4eafa65307c3eb/lib/fluent/plugin/output.rb#L1305-L1310)
         3. [submit_flush_all](https://github.com/fluent/fluentd/blob/1c28d6ed0cf346c322fbca92bb4eafa65307c3eb/lib/fluent/plugin/output.rb#L1312-L1317)
         4. [submit_flush_once](https://github.com/fluent/fluentd/blob/1c28d6ed0cf346c322fbca92bb4eafa65307c3eb/lib/fluent/plugin/output.rb#L1290-L1303)
      * `submit_flush_once` でflush_threadをActiveにする
         * [あらびき日記: fluentd のアーキテクチャ -> Threads -> Flush thread](https://abicky.net/2017/10/23/110103/#flush-thread)
   3. shutdown(shutting down)
   4. after_shutdown
   5. close
   6. terminate

   ```
   2020-11-04 11:02:19 +0000 [debug]: #0 fluent/log.rb:306:debug: fluentd main process get SIGTERM
   2020-11-04 11:02:19 +0000 [debug]: #0 fluent/log.rb:306:debug: getting start to shutdown main process
   -> "HTTP/1.1 100 Continue\r\n"
   -> "\r\n"
   -> "HTTP/1.1 200 OK\r\n"
   -> "x-amz-id-2: sUGDIuKCLTUh8fG3is/J7e4mq6pDyVDBR31A11uIV2jzZ/kfSUsJtq6Vet7wmEl4KSmRe8fZ6SI=\r\n"
   -> "x-amz-request-id: 1420E6AAB34358D0\r\n"
   -submit_flush_once> "Date: Wed, 04 Nov 2020 11:02:20 GMT\r\n"
   -> "ETag: \"ad9553c25296cafe8ef1513714365027\"\r\n"
   -> "Content-Length: 0\r\n"
   -> "Server: AmazonS3\r\n"
   -> "\r\n"
   reading 0 bytes...
   -> ""
   read 0 bytes
   Conn keep-alive
   2020-11-04 11:02:19 +0000 [info]: #0 fluent/log.rb:327:info: [Aws::S3::Client 200 0.226464 0 retries] put_object(body:#<Tempfile:/tmp/s3-20201104-30-tlkm7d>,content_type:"application/x-gzip",storage_class:"STANDARD",bucket:"maehachi08",key:"logs/ruby_on_rails_log/2020/10/03/06/00/dc0995e073bc_9.gz")

   2020-11-04 11:02:19 +0000 [trace]: #0 fluent/log.rb:284:trace: write operation done, committing chunk="5b345e9b2519ee83ab44e54bea47a4d2"
   2020-11-04 11:02:19 +0000 [trace]: #0 fluent/log.rb:284:trace: committing write operation to a chunk chunk="5b345e9b2519ee83ab44e54bea47a4d2" delayed=false
   2020-11-04 11:02:19 +0000 [trace]: #0 fluent/log.rb:284:trace: purging a chunk instance=2920 chunk_id="5b345e9b2519ee83ab44e54bea47a4d2" metadata=#<struct Fluent::Plugin::Buffer::Metadata timekey=1601704800, tag="ruby_on_rails.log", variables=nil, seq=0>
   2020-11-04 11:02:19 +0000 [trace]: #0 fluent/log.rb:284:trace: chunk purged instance=2920 chunk_id="5b345e9b2519ee83ab44e54bea47a4d2" metadata=#<struct Fluent::Plugin::Buffer::Metadata timekey=1601704800, tag="ruby_on_rails.log", variables=nil, seq=0>
   2020-11-04 11:02:19 +0000 [trace]: #0 fluent/log.rb:284:trace: done to commit a chunk chunk="5b345e9b2519ee83ab44e54bea47a4d2"

   2020-11-04 11:02:19 +0000 [info]: #0 fluent/log.rb:327:info: fluentd worker is now stopping worker=0
   2020-11-04 11:02:19 +0000 [info]: #0 fluent/log.rb:327:info: shutting down fluentd worker worker=0
   2020-11-04 11:02:19 +0000 [debug]: #0 fluent/log.rb:306:debug: calling stop on input plugin type=:tail plugin_id="object:708"
   2020-11-04 11:02:19 +0000 [debug]: #0 fluent/log.rb:306:debug: calling stop on output plugin type=:forest plugin_id="object:c814"
   2020-11-04 11:02:19 +0000 [debug]: #0 fluent/log.rb:306:debug: preparing shutdown input plugin type=:tail plugin_id="object:708"
   2020-11-04 11:02:19 +0000 [info]: #0 fluent/log.rb:327:info: shutting down input plugin type=:tail plugin_id="object:708"
   2020-11-04 11:02:19 +0000 [trace]: #0 fluent/log.rb:284:trace: writing events into buffer instance=2920 metadata_size=1
   2020-11-04 11:02:19 +0000 [debug]: #0 fluent/log.rb:306:debug: Created new chunk chunk_id="5b345e9c84df4df125c0e8b24b300f50" metadata=#<struct Fluent::Plugin::Buffer::Metadata timekey=1601704800, tag="ruby_on_rails.log", variables=nil, seq=0>
   2020-11-04 11:02:19 +0000 [trace]: #0 fluent/log.rb:284:trace: chunk /var/log/td-agent/buffer/ruby_on_rails_log/buffer.b5b345e9c84df4df125c0e8b24b300f50.log size_added: 300 new_size: 300
   2020-11-04 11:02:19 +0000 [trace]: #0 fluent/log.rb:284:trace: enqueueing chunk instance=2920 metadata=#<struct Fluent::Plugin::Buffer::Metadata timekey=1601704800, tag="ruby_on_rails.log", variables=nil, seq=0>
   2020-11-04 11:02:19 +0000 [trace]: #0 fluent/log.rb:284:trace: dequeueing a chunk instance=2920
   2020-11-04 11:02:19 +0000 [trace]: #0 fluent/log.rb:284:trace: chunk dequeued instance=2920 metadata=#<struct Fluent::Plugin::Buffer::Metadata timekey=1601704800, tag="ruby_on_rails.log", variables=nil, seq=0>
   2020-11-04 11:02:19 +0000 [trace]: #0 fluent/log.rb:284:trace: trying flush for a chunk chunk="5b345e9c84df4df125c0e8b24b300f50"
   2020-11-04 11:02:19 +0000 [trace]: #0 fluent/log.rb:284:trace: adding write count instance=2940
   2020-11-04 11:02:19 +0000 [trace]: #0 fluent/log.rb:284:trace: executing sync write chunk="5b345e9c84df4df125c0e8b24b300f50"
   2020-11-04 11:02:19 +0000 [debug]: #0 fluent/log.rb:306:debug: preparing shutdown output plugin type=:forest plugin_id="object:c814"
   <- "HEAD /logs/ruby_on_rails_log/2020/10/03/06/00/dc0995e073bc_0.gz HTTP/1.1\r\nContent-Type: \r\nAccept-Encoding: \r\nUser-Agent: aws-sdk-ruby3/3.104.3 ruby/2.7.1 x86_64-linux aws-sdk-s3/1.78.0\r\nHost: maehachi08.s3.ap-northeast-1.amazonaws.com\r\nX-Amz-Date: 20201104T110219Z\r\nX-Amz-Content-Sha256: e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855\r\nAuthorization: AWS4-HMAC-SHA256 Credential=AKIAIOMRCKUHKODZO23Q/20201104/ap-northeast-1/s3/aws4_request, SignedHeaders=host;user-agent;x-amz-content-sha256;x-amz-date, Signature=7492e5d4bce0eb5119fb9df130beb189bdece777590b95c7568597d642e8265c\r\nContent-Length: 0\r\nAccept: */*\r\n\r\n"
   2020-11-04 11:02:19 +0000 [info]: #0 fluent/log.rb:327:info: shutting down output plugin type=:forest plugin_id="object:c814"

   2020-11-04 11:02:19 +0000 [debug]: #0 fluent/log.rb:306:debug: calling after_shutdown on input plugin type=:tail plugin_id="object:708"
   2020-11-04 11:02:19 +0000 [debug]: #0 fluent/log.rb:306:debug: calling after_shutdown on output plugin type=:forest plugin_id="object:c814"
   2020-11-04 11:02:19 +0000 [debug]: #0 fluent/log.rb:306:debug: closing input plugin type=:tail plugin_id="object:708"
   2020-11-04 11:02:19 +0000 [debug]: #0 fluent/log.rb:306:debug: closing output plugin type=:forest plugin_id="object:c814"
   2020-11-04 11:02:19 +0000 [debug]: #0 fluent/log.rb:306:debug: calling terminate on input plugin type=:tail plugin_id="object:708"
   2020-11-04 11:02:19 +0000 [debug]: #0 fluent/log.rb:306:debug: calling terminate on output plugin type=:forest plugin_id="object:c814"
   ```
