#!/usr/bin/env bash

# in host
# sudo apt update
# sudo apt install ntp -y
# sudo service ntp restart

GW_ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd -P )"
GW_RES_DIR=$GW_ROOT_DIR/res/misc

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

sudo apt install -y nano pigz bc strace ltrace gdb kmod
# systemd

# dw-samples-src to debug
sudo mkdir -p /opt/gw_demo/res/driveworks/
sudo tar --use-compress-program=pigz -xvpf res/misc/dw-samples-src.tar.gz -C /opt/gw_demo/res/driveworks/

# ros2 runtime-dependencies
sudo apt install -y libboost-thread-dev
sudo apt install -y ros-foxy-demo-nodes-cpp

# ros2 prebuilt-binary
# sudo mkdir -p /opt/ros/foxy-smacc2/
# sudo tar --use-compress-program=pigz -xvpf res/misc/ros-foxy-smacc2.tar.gz -C /opt/ros/foxy-smacc2/
