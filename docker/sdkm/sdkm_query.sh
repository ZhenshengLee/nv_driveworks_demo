#!/usr/bin/env bash

################################################################################
# 基于cuda镜像制作ga_cuda镜像, 安装ros2-humble
# 支持2004 2204
# aarch64需要到aarch64平台计算机运行
# 支持本地或者pull拉取
################################################################################



VERSION_OPT=""
LOCAL_IMAGE="yes"
VERSION=""
ARCH=$(uname -m)
# zs:
VERSION_X86_64_2004="latest"
VERSION_X86_64_2204="latest"

# Check whether user has agreed license agreement
function check_agreement() {

  tip="using this sw means agreeing to the license agreement above"
  echo $tip

}

function show_usage()
{
cat <<EOF
Usage: $(basename $0) [options] ...
OPTIONS:
    just run the shell without parameters
EOF
exit 0
}

function stop_containers()
{
echo "stop_containers"
exit 0
running_containers=$(docker ps --format "{{.Names}}")

for i in ${running_containers[*]}
do
  if [[ "$i" =~ gw_sdkm_* ]];then
    printf %-*s 70 "stopping container: $i ..."
    docker stop $i > /dev/null
    if [ $? -eq 0 ];then
      printf "\033[32m[DONE]\033[0m\n"
    else
      printf "\033[31m[FAILED]\033[0m\n"
    fi
  fi
done
}

##########################提前跑-start#########################################

GW_ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd -P )"
GW_ROS_ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../" && pwd -P )"

source ${GW_ROOT_DIR}/scripts/gw_base.sh
check_agreement


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
    -l|--local)
        LOCAL_IMAGE="yes"
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

if [ ! -z "$VERSION_OPT" ]; then
    VERSION=$VERSION_OPT
elif [ ${ARCH} == "x86_64" ]; then
    VERSION=${VERSION_X86_64}
elif [ ${ARCH} == "aarch64" ]; then
    VERSION=${VERSION_AARCH64}
else
    echo "Unknown architecture: ${ARCH}"
    exit 0
fi

# zs:
# 如果没有制定docker_repo，则默认是sdkmanager
if [ -z "${DOCKER_REPO}" ]; then
    DOCKER_REPO=sdkmanager
fi

# 如果没有制定,默认是22.04
if [ -z "${GW_DIST}" ]; then
    GW_DIST=22.04
    VERSION=${VERSION_X86_64_2204}
else
    GW_DIST=20.04
    VERSION=${VERSION_X86_64_2004}
fi


# 加载的镜像
IMG=${DOCKER_REPO}:$VERSION

##########################提前跑-end#########################################

# 挂在本地代码和日志缓存等数据
function local_volumes() {
    set +x
    # Apollo root and bazel cache dirs are required.
    volumes="-v $GW_ROS_ROOT_DIR:/gw_demo \
            -v /dev/bus/usb:/dev/bus/usb/ \
            -v /media/$USER:/media/nvidia:slave \
             -v $HOME/.cache:${DOCKER_HOME}/.cache"
    case "$(uname -s)" in
        Linux)

            case "$(lsb_release -r | cut -f2)" in
                14.04)
                    volumes="${volumes} "
                    ;;
                *)
                    volumes="${volumes} -v /dev:/dev "
                    ;;
            esac
            volumes="${volumes} -v /media:/media \
                                -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
                                -v /etc/localtime:/etc/localtime:ro \
                                -v /usr/src:/usr/src \
                                -v /lib/mgaules:/lib/mgaules"
            ;;
        Darwin)
            # MacOS has strict limitations on mapping volumes.
            chmod -R a+wr ~/.cache/bazel
            ;;
    esac
    echo "${volumes}"
}

# 主函数
function main(){

    # 是否使用本地镜像
    if [ "$LOCAL_IMAGE" = "yes" ];then
        info "Start docker container based on local image : $IMG"
    else
        info "Start pulling docker image $IMG ..."
        docker pull $IMG
        if [ $? -ne 0 ];then
            error "Failed to pull docker image."
            exit 1
        fi
    fi

    # zs:
    GW_CONTAINER_NAME="gw_sdkm_${GW_DIST}_${USER}"
    docker ps -a --format "{{.Names}}" | grep "$GW_CONTAINER_NAME" 1>/dev/null
    # 如果成功
    if [ $? == 0 ]; then
        if [[ "$(docker inspect --format='{{.Config.Image}}' $GW_CONTAINER_NAME 2> /dev/null)" != "$IMG" ]]; then
            rm -rf $GW_ROOT_DIR/colcon/*
            rm -rf $HOME/.cache/bazel/*
        fi
        docker stop $GW_CONTAINER_NAME 1>/dev/null
        docker rm -v -f $GW_CONTAINER_NAME 1>/dev/null
    fi

    # 一些系统信息
    USER_ID=$(id -u)
    GRP=$(id -g -n)
    GRP_ID=$(id -g)
    LOCAL_HOST=`hostname`
    DOCKER_HOME="/home/$USER"
    if [ "$USER" == "root" ];then
        DOCKER_HOME="/root"
    fi
    if [ ! -d "$HOME/.cache" ];then
        mkdir "$HOME/.cache"
    fi

    info "Starting docker container \"${GW_CONTAINER_NAME}\" ..."

    # Check nvidia-driver and GPU device.
    USE_GPU=0
    if [ -z "$(which nvidia-smi)" ]; then
      warning "No nvidia-driver found! Use CPU."
    elif [ -z "$(nvidia-smi)" ]; then
      warning "No GPU device found! Use CPU."
    else
      USE_GPU=1
    fi

    # Try to use GPU in container.
    DOCKER_RUN="docker run"
    NVIDIA_DOCKER_DOC="https://github.com/NVIDIA/nvidia-docker/blob/master/README.md"
    if [ ${USE_GPU} -eq 1 ]; then
      DOCKER_VERSION=$(docker version --format '{{.Server.Version}}')
      if ! [ -z "$(which nvidia-docker)" ]; then
        DOCKER_RUN="nvidia-docker run"
        warning "nvidia-docker is in deprecation!"
        warning "Please install latest docker and nvidia-container-toolkit: ${NVIDIA_DOCKER_DOC}"
      elif ! [ -z "$(which nvidia-container-toolkit)" ]; then
        if dpkg --compare-versions "${DOCKER_VERSION}" "ge" "19.03"; then
          DOCKER_RUN="docker run --gpus all"
        else
          warning "You must upgrade to docker-ce 19.03+ to access GPU from container!"
          USE_GPU=0
        fi
      else
        USE_GPU=0
        warning "Cannot access GPU from container."
        warning "Please install latest docker and nvidia-container-toolkit: ${NVIDIA_DOCKER_DOC}"
      fi
    fi

    set -x

    docker run -it \
        --privileged \
        --name $GW_CONTAINER_NAME \
        -e DOCKER_IMG=$IMG \
        $(local_volumes) \
        --net host \
        -w /gw_demo \
        --add-host in_dev_docker:127.0.0.1 \
        --add-host ${LOCAL_HOST}:127.0.0.1 \
        --hostname in_dev_docker \
        --shm-size 2G \
        --pid=host \
        -v /dev/null:/dev/raw1394 \
        $IMG \
        --query interactive \
        --logintype devzone \
        --license accept \
        --staylogin true \
        --datacollection disable \
        # /bin/bash drive-sdk-docker
    if [ $? -ne 0 ];then
        error "Failed to start docker container \"${GW_CONTAINER_NAME}\" based on image: $IMG"
        exit 1
    fi
    set +x

    # if [ "${USER}" != "root" ]; then
    #     docker exec $GW_CONTAINER_NAME bash -c '/gw_demo/scripts/docker_adduser.sh'
    # fi

    ok "Finished setting up ga_team/gw origin environment. Now you can enter with: \nbash docker/build/docker_into.sh "
    ok "Enjoy!"
}

main
