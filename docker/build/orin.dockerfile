# https://yeasy.gitbook.io/docker_practice/image/build
# docker build -t arm64v8/ros:foxy-dev -f ./docker/build/orin.dockerfile .
# docker save -o arm64v8-ros-foxy-dev.tar arm64v8/ros:foxy-dev
# 原则：环境变量docker-run后加，文件固化在docker中
FROM arm64v8/ros:foxy

# 安装deb依赖
RUN set -x; \
    cp /etc/apt/sources.list /etc/apt/sources.list.bak \
    && sed -i 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list \
    && sed -i 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list \
    && sed -i 's/ports.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list \
    && sed -i 's/packages.ros.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list.d/ros2-latest.list \
    && apt update \
    && apt install -y systemd nano pigz bc strace ltrace gdb kmod \
    && rm -rf /var/lib/apt/lists/* \
    && rm /etc/apt/sources.list \
    && mv /etc/apt/sources.list.bak /etc/apt/sources.list

ADD res/misc/dw-samples-src.tar.gz /opt/gw_demo/res/driveworks/
