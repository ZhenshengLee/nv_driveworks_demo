#!/usr/bin/env bash

#=================================================
#                   ros环境自动化脚本
#=================================================

# 颜色
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[32m'
WHITE='\033[34m'
YELLOW='\033[33m'
NO_COLOR='\033[0m'

GW_ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"
GW_TARGET_ROOT_DIR=${GW_ROOT_DIR}/target
GW_AARCH64_ROOT_DIR=${GW_TARGET_ROOT_DIR}/aarch64/
GW_AARCH64_BUILD_DIR=${GW_TARGET_ROOT_DIR}/aarch64/build
GW_AARCH64_INSTALL_DIR=${GW_TARGET_ROOT_DIR}/aarch64/install
GW_X86_ROOT_DIR=${GW_TARGET_ROOT_DIR}/x86/
GW_X86_BUILD_DIR=${GW_TARGET_ROOT_DIR}/x86/build
GW_X86_INSTALL_DIR=${GW_TARGET_ROOT_DIR}/x86/install

GW_SYS_ROOT="/drive/drive-linux/filesystem/targetfs"

function source_ga_base() {
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
  cd "${DIR}"

  source ${DIR}/docker/scripts/gw_base.sh
  # source ${GW_SYS_ROOT}/opt/ros/${GW_ROS_DIST}/setup.bash
}

function ga_check_system_config() {
  # check docker environment
    # 检查操作系统规格是否满足要求, 设置一些变量
  # check operating system
  OP_SYSTEM=$(uname -s)
  case $OP_SYSTEM in
    "Linux")
      echo "System check passed. continue ..."
      ;;
    *)
      error "Unsupported system: ${OP_SYSTEM}."
      error "Please use Linux, we recommend Ubuntu 20.04."
      exit 1
  esac

  # 检测是20.04还是18.04
  case "$(lsb_release -r | cut -f2)" in
      20.04)
        GW_ROS_DIST="foxy"
        ;;
      22.04)
      GW_ROS_DIST="humble"
        ;;
      *)
      error "Unsupported ubuntu distro"
      error "Please use Linux, we recommend Ubuntu 20.04."
      exit 1
  esac
}

function check_machine_arch() {
  # the machine type, currently support x86_64, aarch64
  MACHINE_ARCH=$(uname -m)

}

#=================================================
#              Build functions
#=================================================

function cmake_aarch64() {
  info "Start cmake, please wait ..."
  info "cmake on $MACHINE_ARCH..."

  cd ${GW_ROOT_DIR}
  info "cmake -B ${GW_AARCH64_BUILD_DIR} ${CMAKE_BUILD_OPT} ${CMAKE_CROSS_OPT}"
  cmake -B ${GW_AARCH64_BUILD_DIR} ${CMAKE_BUILD_OPT} ${CMAKE_CROSS_OPT}

  if [ ${PIPESTATUS[0]} -ne 0 ]; then
    fail 'cmake failed!'
  fi
  info "please make_aarch64"
  cd -
  success 'cmake_aarch64 passed!'
}

# https://colcon.readthedocs.io/en/released/user/installation.html
function make_aarch64() {
  info "Start make, please wait ..."
  info "make and install on $MACHINE_ARCH..."

  cd ${GW_ROOT_DIR}
  info "make -C ${GW_AARCH64_BUILD_DIR} ${MAKE_JOB_ARG} ${MAKE_INSTALL_ARG}"
  make -C ${GW_AARCH64_BUILD_DIR} ${MAKE_JOB_ARG} ${MAKE_INSTALL_ARG}

  if [ ${PIPESTATUS[0]} -ne 0 ]; then
    fail 'make failed!'
  fi
  info "make and install completed."
  cd -
  success 'make_aarch64 passed!'
}

function install_aarch64() {
  nfo "Start make, please wait ..."
  info "make install on $MACHINE_ARCH..."

  cd ${GW_ROOT_DIR}
  info "make -C ${GW_AARCH64_BUILD_DIR} ${MAKE_JOB_ARG} ${MAKE_INSTALL_ARG}"
  make -C ${GW_AARCH64_BUILD_DIR} ${MAKE_JOB_ARG} ${MAKE_INSTALL_ARG}

  if [ ${PIPESTATUS[0]} -ne 0 ]; then
    fail 'install failed!'
  fi
  info "please copy the target to orin-kit"
  cd -
  success 'install_aarch64 passed!'
}

# 编译测试检查
function check() {
  bash $0 build && bash $0 "test" && bash $0 lint

  if [ $? -eq 0 ]; then
    success 'Check passed!'
    return 0
  else
    fail 'Check failed!'
    return 1
  fi
}

function warn_proprietary_sw() {
  echo -e "${RED}all rights reserved, ga_team.${NO_COLOR}"
}

function run_unit_test() {

  info "Building on $MACHINE_ARCH..."

  info "Building with $JOB_ARG for $MACHINE_ARCH"

  cd ${GW_ROOT_DIR}
  export GPUAC_COMPILE_WITH_CUDA=1
  # --force-cmake
  info "colcon ${LOG_ARG} test ${COLCON_ARG} ${TEST_ARG} ${JOB_ARG} "
  colcon ${LOG_ARG} test ${COLCON_ARG} ${TEST_ARG} ${JOB_ARG}

  # --packages-up-to
  if [ ${PIPESTATUS[0]} -ne 0 ]; then
    fail 'Test failed!'
  fi
  cd -
  success 'Test passed!'
}

function run_cpp_lint() {
  echo "not support"
}

function run_bash_lint() {
  FILES=$(find "${APOLLO_ROOT_DIR}" -type f -name "*.sh" | grep -v ros)
  echo "${FILES}" | xargs shellcheck
}

function run_lint() {
  # Add cpplint rule to BUILD files that do not contain it.
  run_cpp_lint

  if [ $? -eq 0 ]; then
    success 'Lint passed!'
  else
    fail 'Lint failed!'
  fi
}

function clean() {
  # Remove catkin files
  cd ${GW_ROOT_DIR}
  info "Start cleaning, please wait ..."

  info "rm -rf  ${GW_AARCH64_ROOT_DIR}/*"
  rm -rf  ${GW_AARCH64_ROOT_DIR}/*

  info "rm -rf  ${GW_X86_ROOT_DIR}/*"
  rm -rf  ${GW_X86_ROOT_DIR}/*

  cd -
  success "clean passed!"
}

function gen_doc() {
  echo "not support"
}

function version() {
  echo "not support"
}

function get_revision() {
  echo "not support"
}

function get_branch() {
  git branch &> /dev/null
  if [ $? = 0 ];then
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
  else
    warning "Could not get the branch name, maybe this is not a git work tree." >&2
    BRANCH="unknown"
  fi
  echo "$BRANCH"
}

function config() {
  MAKE_INSTALL_ARG=" install"
  MAKE_JOB_ARG="-j $(($(nproc)-1))"
  if [ "$MACHINE_ARCH" == 'aarch64' ]; then
    MAKE_JOB_ARG="-j $(($(nproc)-2))"
  fi
  CMAKE_BUILD_OPT=" -DBUILD_TESTING=OFF --no-warn-unused-cli "
  CMAKE_CROSS_OPT=" -DCMAKE_TOOLCHAIN_FILE=/gw_demo/cmake/Toolchain-V5L.cmake -DVIBRANTE_PDK=/drive/drive-linux "
  # --cmake-force-configure
}

function set_use_gpu() {
  echo "not support"
}

function print_usage() {
  RED='\033[0;31m'
  BLUE='\033[0;34m'
  BOLD='\033[1m'
  NONE='\033[0m'

  echo -e "\n${RED}Usage${NONE}:
  .${BOLD}/gw.sh${NONE} [OPTION]"

  echo -e "\n${RED}Options${NONE}:
  ${BLUE}cmake_aarch64${NONE}: cmake_aarch64
  ${BLUE}make_aarch64${NONE}: make and install on aarch64
  ${BLUE}install_aarch64${NONE}: install_aarch64
  ${BLUE}clean${NONE}: clean
  ${BLUE}usage${NONE}: print this menu
  "
  # ${BLUE}build_rel${NONE}: build_rel
  # ${BLUE}build_rel_dbg${NONE}: build rel with dbg info
  # ${BLUE}pkg_rel${NONE}: pkg_rel
  # ${BLUE}dpkg_install${NONE}: install deb files
  # ${BLUE}unit_test${NONE}: run all unit tests
  # ${BLUE}check_hardware${NONE}: run programs to check hardwares
  # ${BLUE}check_algorithm${NONE}: run programs to check algorithms
  # ${BLUE}doc${NONE}: generate doxygen document
}

function main() {
  ga_check_system_config
  source_ga_base
  check_machine_arch
  config

  if [ ${MACHINE_ARCH} == "x86_64" ]; then
    echo "x86_64"
  fi

  local cmd=$1
  shift

  START_TIME=$(get_now)
  case $cmd in
    cmake_aarch64)
      cmake_aarch64 $@
      ;;
    make_aarch64)
      make_aarch64 $@
      ;;
    install_aarch64)
      install_aarch64 $@
      ;;
    clean)
      clean
      ;;
    usage)
      print_usage
      ;;
    *)
      print_usage
      ;;
  esac
  # build_rel_dbg)
  #     build_rel_dbg $@
  #     ;;
  #   build_rel)
  #     build_rel $@
  #     ;;
  # pkg_rel)
  #     pkg_rel $@
  #     ;;
  #   unit_test)
  #     run_unit_test $@
  #     ;;
  #   dpkg_install)
  #     dpkg_install $@
  #     ;;
  #   check_hardware)
  #     check_hardware $@
  #     ;;
  #   check_algorithm)
  #     check_algorithm $@
  #     ;;
  #   catkin)
  #     catkin $@
  #     ;;
  #   config)
  #     config
  #     ;;
  #   doc)
  #     gen_doc
  #     ;;
}

main $@
