#!/usr/bin/env bash

# in host
# sudo apt update
# sudo apt install ntp -y
# sudo service ntp restart

set -e

if [ -f /.dockerenv ]; then
    echo "I am running on Docker."
else
    echo "I am running on Host."
fi

# 额外安装软件
sudo apt update
sudo apt install python3-pip -y
pip3 config set global.trusted-host mirrors.xlab.gacrnd.com
pip3 config set global.index-url http://mirrors.xlab.gacrnd.com/repository/pypi/simple
sudo pip3 config set global.trusted-host mirrors.xlab.gacrnd.com
sudo pip3 config set global.index-url http://mirrors.xlab.gacrnd.com/repository/pypi/simple

sudo apt install -y nano pigz bc strace ltrace gdb
# systemd

# dw-samples-src to debug
sudo mkdir -p /opt/gw_demo/res/driveworks/
sudo tar --use-compress-program=pigz -xvpf res/dw-samples-src.tar.gz -C /opt/gw_demo/res/driveworks/

# ros2 runtime-dependencies
sudo apt install -y libboost-thread-dev
sudo apt install -y ros-foxy-demo-nodes-cpp

# ros2 prebuilt-binary
sudo mkdir -p /opt/ros/foxy-smacc2/
sudo tar --use-compress-program=pigz -xvpf res/ros-foxy-smacc2.tar.gz -C /opt/ros/foxy-smacc2/

# tcp_pubsub
sudo mkdir -p /opt/xlab/sysroot
sudo tar --use-compress-program=pigz -xvpf res/tcp_pubsub-1.0.4-Linux.tar.gz -C /opt/xlab/sysroot
sudo tar --use-compress-program=pigz -xvpf res/tcp_pubsub_bin.tar.gz -C /opt/xlab/sysroot
