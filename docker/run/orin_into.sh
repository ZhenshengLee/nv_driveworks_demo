#!/usr/bin/env bash

# 进入某个容器
# 必须制定一个参数：容器名
# 选择制定一个参数：是否root，默认非root

GW_DIST=""

function show_usage()
{
cat <<EOF
Usage: $(basename $0) [options] ...
OPTIONS:
    -d 22.04
    -d 20.04
EOF
exit 0
}

# 参数校验
while [ $# -gt 0 ]
do
    case "$1" in
    -d|--dist)
        VAR=$1
        GW_DIST=$VAR
        ;;
    -h|--help)
        show_usage
        ;;
    stop)
    stop_containers
    exit 0
    ;;
    *)
        echo -e "\033[93mWarning\033[0m: Unknown option: $1"
        exit 2
        ;;
    esac
    shift
done

# zs:
# 如果没有制定,默认是20.04
if [ -z "${GW_DIST}" ]; then
    GW_DIST=20.04
else
    GW_DIST=22.04
fi

xhost +local:root 1>/dev/null 2>&1
docker exec \
    -u $USER \
    -e HISTFILE=/target/.dev_bash_hist \
    -it gw_orin_${GW_DIST}_$USER \
    /bin/bash

# https://github.com/multiarch/qemu-user-static/issues/17
# docker exec \
#     -u root \
#     -e HISTFILE=/target/.dev_bash_hist \
#     -it gw_orin_${GW_DIST}_$USER \
#     /bin/bash

xhost -local:root 1>/dev/null 2>&1