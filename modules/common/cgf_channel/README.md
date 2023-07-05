# channel

## 测试工具

```sh
# inter-process-socket
./dwchannel_test --cons=1 --prod=1 --downstreams=1 --dataType=custom
./dwchannel_test --cons=1 --prod=1 --downstreams=1 --dataType=int
./dwchannel_test --cons=1 --prod=1 --downstreams=1 --dataType=dwImage

# inter-process-nvsci
# t1: producer
./dwchannel_test --type=NVSCI --prod-stream-names=nvscisync_a_0 --prod-reaches=process --dataType=custom
# t2: consumer
./dwchannel_test --type=NVSCI --cons-stream-names=nvscisync_a_1 --cons-reaches=process --dataType=custom

#
```

## sample_dwchannel

```sh
# inter-process-socket
./sample_cgf_dwchannel --cons=1 --prod=1 --downstreams=1 --dataType=custom
./sample_cgf_dwchannel --cons=1 --prod=1 --downstreams=1 --dataType=int
./sample_cgf_dwchannel --cons=1 --prod=1 --downstreams=1 --dataType=dwImage

# inter-process-nvsci
# t1: producer
./sample_cgf_dwchannel --type=NVSCI --prod-stream-names=nvscisync_a_0 --prod-reaches=process --dataType=custom
# t2: consumer
./sample_cgf_dwchannel --type=NVSCI --cons-stream-names=nvscisync_a_1 --cons-reaches=process --dataType=custom

#
```

## sample_nvstream

```sh
# Single-process NvMedia/CUDA stream with three consumers, and the second uses the mailbox mode
./nvscistream_event_sample -u 2 -m 3 -q 1 m

# Multi-process CUDA/CUDA stream with three consumers, one in the same
# process as the producer, and the other two in separate processes. The
# first and the third consumers use the mailbox mode:
./nvscistream_event_sample -m 3 -p -c 0 -q 0 m &
./nvscistream_event_sample -c 1 -c 2 -q 2 m
```
