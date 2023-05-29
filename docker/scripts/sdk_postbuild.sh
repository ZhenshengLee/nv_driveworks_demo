#!/usr/bin/env bash

set -e

# 额外安装软件
sudo apt update
sudo apt install python3-numpy -y
sudo apt install python3-pip -y
pip3 config set global.trusted-host https://pypi.tuna.tsinghua.edu.cn
pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
sudo pip3 config set global.trusted-host https://pypi.tuna.tsinghua.edu.cn
sudo pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
sudo -H python3 -m pip install jsonschema
# gtest 暂不实施
# sudo apt install libgtest-dev
# cd /usr/src/gtest
# sudo cmake CMakeLists.txt
# sudo make
# sudo cp lib/*.a /usr/lib

# ros2 development tool
sudo tar --use-compress-program=pigz -xvpf res/ros-foxy.tar.gz -C /drive/drive-linux/filesystem/targetfs/
export ROS2_HOME=/drive/drive-linux/filesystem/targetfs/opt/ros/foxy/
export PYTHONPATH=${ROS2_HOME}/lib/python3.8/site-packages
export PATH=${PATH}:${ROS2_HOME}/bin
sudo -H python3 -m pip install -U vcstool colcon-common-extensions lark
sudo dpkg --add-architecture arm64
sudo apt install libspdlog-dev:arm64 libyaml-dev:arm64 libpython3-dev:arm64 libtinyxml2-dev:arm64 libssl-dev:arm64 openssl:arm64 -y
# ros2 cross-build in python: break host python config.
sudo cp /usr/include/aarch64-linux-gnu/python3.8/pyconfig.h /usr/include/python3.8/

# ros2 cross-build dependencies: may break host drivesdk environment
sudo apt install -y libboost-dev:arm64 libboost-thread-dev:arm64
# uuid-dev:arm64 break driveos

# header-only boost support
sudo ln -s /usr/include/boost /drive/drive-linux/include/boost

# ros2 prebuilt-binary
sudo mkdir -p /drive/drive-linux/filesystem/targetfs/opt/ros/foxy-smacc2/
sudo tar --use-compress-program=pigz -xvpf res/ros-foxy-smacc2.tar.gz -C /drive/drive-linux/filesystem/targetfs/opt/ros/foxy-smacc2/

# tcp_pubsub
sudo mkdir -p /opt/xlab/sysroot
sudo tar --use-compress-program=pigz -xvpf res/tcp_pubsub-1.0.4-Linux.tar.gz -C /opt/xlab/sysroot
