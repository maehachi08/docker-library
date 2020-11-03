# flush_at_shutdown

## multilineでの注意点

* **out_s3 pluginのflush_at_shutdown処理が file_buffer plugin の memory bufferをファイルへ書き出すより前に実行されている**
   * [lib/fluent/root_agent.rb#L265-L266](https://github.com/fluent/fluentd/blob/9ff9d79425b903cd1c16ce13c156b213ba47d5d7/lib/fluent/root_agent.rb#L265-L266)
   * https://github.com/fluent/fluentd/issues/1740#issuecomment-346933621

```
^C2020-11-03 14:07:48 +0000 [debug]: #0 fluent/log.rb:306:debug: fluentd main process get SIGINT
2020-11-03 14:07:48 +0000 [info]: fluent/log.rb:327:info: Received graceful stop
2020-11-03 14:07:48 +0000 [trace]: #0 fluent/log.rb:284:trace: dequeueing a chunk instance=2920
2020-11-03 14:07:48 +0000 [trace]: #0 fluent/log.rb:284:trace: chunk dequeued instance=2920 metadata=#<struct Fluent::Plugin::Buffer::Metadata timekey=1601704800, tag="ruby_
on_rails.log", variables=nil, seq=0>
2020-11-03 14:07:48 +0000 [trace]: #0 fluent/log.rb:284:trace: trying flush for a chunk chunk="5b334632917df2fde5e9baa243180887"
2020-11-03 14:07:48 +0000 [trace]: #0 fluent/log.rb:284:trace: adding write count instance=2940
2020-11-03 14:07:48 +0000 [trace]: #0 fluent/log.rb:284:trace: executing sync write chunk="5b334632917df2fde5e9baa243180887"
opening connection to maehachi08.s3.ap-northeast-1.amazonaws.com:443...
opened
starting SSL for maehachi08.s3.ap-northeast-1.amazonaws.com:443...
SSL established, protocol: TLSv1.2, cipher: ECDHE-RSA-AES128-GCM-SHA256
<- "HEAD /logs/ruby_on_rails_log/2020/10/03/06/00/9ae5a0857419_e8bd4e84-b593-421f-a3e3-f0dca203c9b2_0.gz HTTP/1.1\r\nContent-Type: \r\nAccept-Encoding: \r\nUser-Agent: aws-s
dk-ruby3/3.104.3 ruby/2.7.1 x86_64-linux aws-sdk-s3/1.78.0\r\nHost: maehachi08.s3.ap-northeast-1.amazonaws.com\r\nX-Amz-Date: 20201103T140748Z\r\nX-Amz-Content-Sha256: e3b0c
44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855\r\nAuthorization: AWS4-HMAC-SHA256 Credential=AKIAIOMRCKUHKODZO23Q/20201103/ap-northeast-1/s3/aws4_request, Signe
dHeaders=host;user-agent;x-amz-content-sha256;x-amz-date, Signature=6b4679c88c6eb53042918e7ee472722149abb3c7f9f5582a272829afadaae04f\r\nContent-Length: 0\r\nAccept: */*\r\n\
r\n"
-> "HTTP/1.1 404 Not Found\r\n"
-> "x-amz-request-id: 2DDAB1D0CF191C22\r\n"
-> "x-amz-id-2: KZz+2cI//bgDHZGabScCvY/mdC6C296IjlMeMalg3uB2ussi/GoLbPU/fXmipLTFYsjOTJxBdaU=\r\n"
-> "Content-Type: application/xml\r\n"
-> "Date: Tue, 03 Nov 2020 14:07:48 GMT\r\n"
-> "Server: AmazonS3\r\n"
-> "Connection: close\r\n"
-> "\r\n"
Conn close
2020-11-03 14:07:48 +0000 [info]: #0 fluent/log.rb:327:info: [Aws::S3::Client 404 0.155119 0 retries] head_object(bucket:"maehachi08",key:"logs/ruby_on_rails_log/2020/10/03/
06/00/9ae5a0857419_e8bd4e84-b593-421f-a3e3-f0dca203c9b2_0.gz") Aws::S3::Errors::NotFound

2020-11-03 14:07:48 +0000 [debug]: #0 fluent/log.rb:306:debug: out_s3: write chunk 5b334632917df2fde5e9baa243180887 with metadata #<struct Fluent::Plugin::Buffer::Metadata timekey=1601704800, tag="ruby_on_rails.log", variables=nil, seq=0> to s3://maehachi08/logs/ruby_on_rails_log/2020/10/03/06/00/9ae5a0857419_e8bd4e84-b593-421f-a3e3-f0dca203c9b
2_0.gz
opening connection to maehachi08.s3.ap-northeast-1.amazonaws.com:443...
opened
starting SSL for maehachi08.s3.ap-northeast-1.amazonaws.com:443...
SSL established, protocol: TLSv1.2, cipher: ECDHE-RSA-AES128-GCM-SHA256
<- "PUT /logs/ruby_on_rails_log/2020/10/03/06/00/9ae5a0857419_e8bd4e84-b593-421f-a3e3-f0dca203c9b2_0.gz HTTP/1.1\r\nContent-Type: application/x-gzip\r\nAccept-Encoding: \r\n
User-Agent: aws-sdk-ruby3/3.104.3 ruby/2.7.1 x86_64-linux aws-sdk-s3/1.78.0\r\nX-Amz-Storage-Class: STANDARD\r\nExpect: 100-continue\r\nContent-Md5: muFhRZVgWpVsN8kTs9e6iQ==
\r\nHost: maehachi08.s3.ap-northeast-1.amazonaws.com\r\nX-Amz-Date: 20201103T140748Z\r\nX-Amz-Content-Sha256: a558a4ff840cd6d3ee26a70911b6edfef0c72e388a05276f79c6539b0cbf90d
5\r\nAuthorization: AWS4-HMAC-SHA256 Credential=AKIAIOMRCKUHKODZO23Q/20201103/ap-northeast-1/s3/aws4_request, SignedHeaders=content-md5;content-type;host;user-agent;x-amz-co
ntent-sha256;x-amz-date;x-amz-storage-class, Signature=c3ed093a3e21cd9af2b7ee730f6af5f689bb4b13f513013dcaebac4c7344a046\r\nContent-Length: 211\r\nAccept: */*\r\n\r\n"
-> "HTTP/1.1 100 Continue\r\n"
-> "\r\n"
2020-11-03 14:07:49 +0000 [debug]: #0 fluent/log.rb:306:debug: fluentd main process get SIGTERM
2020-11-03 14:07:49 +0000 [debug]: #0 fluent/log.rb:306:debug: getting start to shutdown main process
-> "HTTP/1.1 200 OK\r\n"
-> "x-amz-id-2: 01QBBYvJSwcyHct/bWtT3MpuFVaxR2WcNo4aULKLbvCFQ1WLO5Nb7gW3GJD+LrEvYsh7BC4b2qs=\r\n"
-> "x-amz-request-id: 094D7A51D0FAD487\r\n"
-> "Date: Tue, 03 Nov 2020 14:07:50 GMT\r\n"
-> "ETag: \"9ae1614595605a956c37c913b3d7ba89\"\r\n"
-> "Content-Length: 0\r\n"
-> "Server: AmazonS3\r\n"
-> "\r\n"
reading 0 bytes...
-> ""
read 0 bytes
Conn keep-alive
2020-11-03 14:07:49 +0000 [info]: #0 fluent/log.rb:327:info: [Aws::S3::Client 200 0.170849 0 retries] put_object(body:#<Tempfile:/tmp/s3-20201103-297-m3puj1>,content_type:"a
pplication/x-gzip",storage_class:"STANDARD",bucket:"maehachi08",key:"logs/ruby_on_rails_log/2020/10/03/06/00/9ae5a0857419_e8bd4e84-b593-421f-a3e3-f0dca203c9b2_0.gz")

2020-11-03 14:07:49 +0000 [trace]: #0 fluent/log.rb:284:trace: write operation done, committing chunk="5b334632917df2fde5e9baa243180887"
2020-11-03 14:07:49 +0000 [trace]: #0 fluent/log.rb:284:trace: committing write operation to a chunk chunk="5b334632917df2fde5e9baa243180887" delayed=false
2020-11-03 14:07:49 +0000 [trace]: #0 fluent/log.rb:284:trace: purging a chunk instance=2920 chunk_id="5b334632917df2fde5e9baa243180887" metadata=#<struct Fluent::Plugin::Bu
ffer::Metadata timekey=1601704800, tag="ruby_on_rails.log", variables=nil, seq=0>
2020-11-03 14:07:49 +0000 [trace]: #0 fluent/log.rb:284:trace: chunk purged instance=2920 chunk_id="5b334632917df2fde5e9baa243180887" metadata=#<struct Fluent::Plugin::Buffe
r::Metadata timekey=1601704800, tag="ruby_on_rails.log", variables=nil, seq=0>
2020-11-03 14:07:49 +0000 [trace]: #0 fluent/log.rb:284:trace: done to commit a chunk chunk="5b334632917df2fde5e9baa243180887"
2020-11-03 14:07:49 +0000 [info]: #0 fluent/log.rb:327:info: fluentd worker is now stopping worker=0
2020-11-03 14:07:49 +0000 [info]: #0 fluent/log.rb:327:info: shutting down fluentd worker worker=0
2020-11-03 14:07:49 +0000 [debug]: #0 fluent/log.rb:306:debug: calling stop on input plugin type=:tail plugin_id="object:708"
2020-11-03 14:07:49 +0000 [debug]: #0 fluent/log.rb:306:debug: calling stop on output plugin type=:forest plugin_id="object:25a8"
2020-11-03 14:07:49 +0000 [debug]: #0 fluent/log.rb:306:debug: preparing shutdown input plugin type=:tail plugin_id="object:708"
2020-11-03 14:07:49 +0000 [info]: #0 fluent/log.rb:327:info: shutting down input plugin type=:tail plugin_id="object:708"
2020-11-03 14:07:49 +0000 [trace]: #0 fluent/log.rb:284:trace: writing events into buffer instance=2920 metadata_size=1
2020-11-03 14:07:49 +0000 [debug]: #0 fluent/log.rb:306:debug: Created new chunk chunk_id="5b334634fc37d8e87ac5b896ab9710d4" metadata=#<struct Fluent::Plugin::Buffer::Metada
ta timekey=1601704800, tag="ruby_on_rails.log", variables=nil, seq=0>
2020-11-03 14:07:49 +0000 [trace]: #0 fluent/log.rb:284:trace: chunk /var/log/td-agent/buffer/ruby_on_rails_log/buffer.b5b334634fc37d8e87ac5b896ab9710d4.log size_added: 300
new_size: 300
2020-11-03 14:07:49 +0000 [debug]: #0 fluent/log.rb:306:debug: preparing shutdown output plugin type=:forest plugin_id="object:25a8"
2020-11-03 14:07:49 +0000 [info]: #0 fluent/log.rb:327:info: shutting down output plugin type=:forest plugin_id="object:25a8"
2020-11-03 14:07:49 +0000 [debug]: #0 fluent/log.rb:306:debug: calling after_shutdown on input plugin type=:tail plugin_id="object:708"
2020-11-03 14:07:49 +0000 [debug]: #0 fluent/log.rb:306:debug: calling after_shutdown on output plugin type=:forest plugin_id="object:25a8"
2020-11-03 14:07:49 +0000 [debug]: #0 fluent/log.rb:306:debug: closing input plugin type=:tail plugin_id="object:708"
2020-11-03 14:07:49 +0000 [debug]: #0 fluent/log.rb:306:debug: closing output plugin type=:forest plugin_id="object:25a8"
2020-11-03 14:07:49 +0000 [debug]: #0 fluent/log.rb:306:debug: calling terminate on input plugin type=:tail plugin_id="object:708"
2020-11-03 14:07:49 +0000 [debug]: #0 fluent/log.rb:306:debug: calling terminate on output plugin type=:forest plugin_id="object:25a8"
2020-11-03 14:07:49 +0000 [warn]: #0 fluent/log.rb:348:warn: thread doesn't exit correctly (killed or other reason) plugin=Fluent::Plugin::S3Output title=:flush_thread_0 thr
ead=#<Thread:0x00007fdd6cacfdb8@flush_thread_0 /opt/td-agent/lib/ruby/gems/2.7.0/gems/fluentd-1.11.2/lib/fluent/plugin_helper/thread.rb:70 aborting> error=nil
2020-11-03 14:07:49 +0000 [warn]: #0 fluent/log.rb:348:warn: thread doesn't exit correctly (killed or other reason) plugin=Fluent::Plugin::S3Output title=:enqueue_thread thr
ead=#<Thread:0x00007fdd6cacef58@enqueue_thread /opt/td-agent/lib/ruby/gems/2.7.0/gems/fluentd-1.11.2/lib/fluent/plugin_helper/thread.rb:70 aborting> error=nil
2020-11-03 14:07:49 +0000 [warn]: #0 fluent/log.rb:348:warn: thread doesn't exit correctly (killed or other reason) plugin=Fluent::Plugin::S3Output title=:flush_thread_4 thr
ead=#<Thread:0x00007fdd6cacf1b0@flush_thread_4 /opt/td-agent/lib/ruby/gems/2.7.0/gems/fluentd-1.11.2/lib/fluent/plugin_helper/thread.rb:70 aborting> error=nil
2020-11-03 14:07:49 +0000 [warn]: #0 fluent/log.rb:348:warn: thread doesn't exit correctly (killed or other reason) plugin=Fluent::Plugin::S3Output title=:flush_thread_1 thr
ead=#<Thread:0x00007fdd6cacfa98@flush_thread_1 /opt/td-agent/lib/ruby/gems/2.7.0/gems/fluentd-1.11.2/lib/fluent/plugin_helper/thread.rb:70 aborting> error=nil
2020-11-03 14:07:49 +0000 [warn]: #0 fluent/log.rb:348:warn: thread doesn't exit correctly (killed or other reason) plugin=Fluent::Plugin::S3Output title=:flush_thread_3 thr
ead=#<Thread:0x00007fdd6cacf4a8@flush_thread_3 /opt/td-agent/lib/ruby/gems/2.7.0/gems/fluentd-1.11.2/lib/fluent/plugin_helper/thread.rb:70 aborting> error=nil
2020-11-03 14:07:49 +0000 [warn]: #0 fluent/log.rb:348:warn: thread doesn't exit correctly (killed or other reason) plugin=Fluent::Plugin::S3Output title=:flush_thread_2 thr
ead=#<Thread:0x00007fdd6cacf7a0@flush_thread_2 /opt/td-agent/lib/ruby/gems/2.7.0/gems/fluentd-1.11.2/lib/fluent/plugin_helper/thread.rb:70 aborting> error=nil
```


