################################################################################
#
# Notice
# ALL NVIDIA DESIGN SPECIFICATIONS AND CODE ("MATERIALS") ARE PROVIDED "AS IS"
# NVIDIA MAKES NO REPRESENTATIONS, WARRANTIES, EXPRESSED, IMPLIED, STATUTORY, OR
# OTHERWISE WITH RESPECT TO THE MATERIALS, AND EXPRESSLY DISCLAIMS ANY IMPLIED
# WARRANTIES OF NONINFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR A PARTICULAR
# PURPOSE.
#
# NVIDIA CORPORATION & AFFILIATES assumes no responsibility for the consequences
# of use of such information or for any infringement of patents or other rights
# of third parties that may result from its use. No license is granted by
# implication or otherwise under any patent or patent rights of NVIDIA
# CORPORATION & AFFILIATES. No third party distribution is allowed unless
# expressly authorized by NVIDIA. Details are subject to change without notice.
# This code supersedes and replaces all information previously supplied. NVIDIA
# CORPORATION & AFFILIATES products are not authorized for use as critical
# components in life support devices or systems without express written approval
# of NVIDIA CORPORATION & AFFILIATES.
#
# SPDX-FileCopyrightText: Copyright (c) 2016-2021 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: LicenseRef-NvidiaProprietary
#
# NVIDIA CORPORATION, its affiliates and licensors retain all intellectual
# property and proprietary rights in and to this material, related documentation
# and any modifications thereto. Any use, reproduction, disclosure or
# distribution of this material and related documentation without an express
# license agreement from NVIDIA CORPORATION or its affiliates is strictly
# prohibited.
#
################################################################################

project(dwcgf_helloworld C CXX)

include(GWSampleInstallConfig)

set(DRIVEWORKS_PATH "/usr/local/driveworks")
set(DWCGF_GRAPHS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/graphs)
set(DWCGF_NODES_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src/nodes)
set(DWCGF_SCHE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/schedule)
set(DWCGF_DATA_DIR ${CMAKE_CURRENT_SOURCE_DIR}/data)
set(DWCGF_RUNNER ${CMAKE_CURRENT_SOURCE_DIR}/bin/run_cgf.sh)
set(DWCGF_RIG_TESTER ${CMAKE_CURRENT_SOURCE_DIR}/bin/test_rig.sh)

file(GLOB_RECURSE DWCGF_NODES_FILES
    ${DWCGF_NODES_DIR}/*.hpp
    ${DWCGF_NODES_DIR}/*.cpp
)

if (NOT TARGET driveworks-shared)
    find_package(driveworks-shared REQUIRED CONFIG HINTS ${DRIVEWORKS_PATH}/cmake)
endif()

if (NOT TARGET dwframework)
    find_package(dwframework REQUIRED CONFIG HINTS ${DRIVEWORKS_PATH}/cmake)
endif()

set(LIBRARIES
    # samples_framework
    ${Driveworks_LIBRARIES}
    driveworks-shared
    dwframework
)

#-------------------------------------------------------------------------------
# ros2 packages
#-------------------------------------------------------------------------------
find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(std_msgs REQUIRED)

# tcp_pubsub
find_package(tcp_pubsub REQUIRED)

# tools
add_executable(tcp2ros ./tools/tcp2ros.cpp)
ament_target_dependencies(tcp2ros "rclcpp" "std_msgs" )
target_link_libraries(tcp2ros tcp_pubsub::tcp_pubsub)
gw_add_sample(tcp2ros)

#-------------------------------------------------------------------------------
# Custom nodes shared library
#-------------------------------------------------------------------------------
add_library(${PROJECT_NAME} SHARED ${DWCGF_NODES_FILES})
ament_target_dependencies(${PROJECT_NAME} "rclcpp" "std_msgs" )
target_link_libraries(${PROJECT_NAME} ${LIBRARIES} tcp_pubsub::tcp_pubsub)
target_include_directories(${PROJECT_NAME}
                           PUBLIC
                           ${CUDA_DIR}/include
                           ${DW_ROOT}/include
                           ${DW_ROOT}/include/3rdparty
                           ${DW_ROOT}/include/dwshared/dwfoundation
                           ${DW_ROOT}/include/dwshared/dwtrace)

set(DWCGF_YAML ${CMAKE_CURRENT_SOURCE_DIR}/schedule/DWCGFHelloworld__standardSchedule.yaml)
set(DWCGF_STM ${CMAKE_CURRENT_SOURCE_DIR}/schedule/DWCGFHelloworld__standardSchedule.stm)

file(GLOB_RECURSE DWCGF_GRAPHS_FILES
    ${DWCGF_GRAPHS_DIR}/*.yaml
    ${DWCGF_GRAPHS_DIR}/*.json
)
# json-validater execute during configuring time.
execute_process(
    COMMAND ${DRIVEWORKS_PATH}/tools/schema/validate_cgfdescriptors.py --ignore-order --ignore-indentation ${DWCGF_GRAPHS_DIR}
    WORKING_DIRECTORY ${DWCGF_GRAPHS_DIR}
    TIMEOUT 3
    RESULT_VARIABLE _EXIT_CODE
    OUTPUT_VARIABLE _OUTPUT_CODE
    COMMAND_ECHO STDOUT
    # OUTPUT_QUIET
    # ERROR_QUIET
    # ECHO_OUTPUT_VARIABLE
    # https://cmake.org/cmake/help/v3.16/command/execute_process.html
)
message(STATUS "${_OUTPUT_CODE}")
# if(NOT _EXIT_CODE EQUAL 0)
#     message(FATAL_ERROR "validate_cgfdescriptors.py failed: please check the json files.")
# endif()
# app2yaml
add_custom_command(
    OUTPUT ${DWCGF_YAML}
    COMMAND ${DRIVEWORKS_PATH}/tools/descriptionScheduleYamlGenerator/descriptionScheduleYamlGenerator.py --app ${DWCGF_GRAPHS_DIR}/app/DWCGFHelloworld.app.json --output DWCGFHelloworld.app.yaml
    WORKING_DIRECTORY ${DWCGF_SCHE_DIR}
    MAIN_DEPENDENCY ${DWCGF_GRAPHS_DIR}/app/DWCGFHelloworld.app.json
    DEPENDS ${DWCGF_GRAPHS_FILES}
    COMMENT "app2yaml...!"
    VERBATIM
)
add_custom_target(${PROJECT_NAME}_yaml ALL DEPENDS ${DWCGF_YAML})
# yaml2stm
add_custom_command(
    OUTPUT ${DWCGF_STM}
    COMMAND ${DRIVEWORKS_PATH}/tools/stmcompiler -i ${DWCGF_YAML}
    WORKING_DIRECTORY ${DWCGF_SCHE_DIR}
    MAIN_DEPENDENCY ${DWCGF_YAML}
    DEPENDS ${PROJECT_NAME}_yaml
    COMMENT "yaml2stm...!"
    VERBATIM
)
add_custom_target(${PROJECT_NAME}_stm ALL DEPENDS ${DWCGF_STM})
# stmvizgraph
# stmvizschedule

# install
# https://blog.csdn.net/qq_38410730/article/details/102837401
set(SDK_GRAPHS_DESTINATION ${GW_SAMPLE_INSTALL_PREFIX})
set(SDK_SCHE_DESTINATION ${GW_SAMPLE_INSTALL_PREFIX})
set(SDK_DATA_DESTINATION ${GW_SAMPLE_INSTALL_PREFIX})
gw_add_sample(${PROJECT_NAME})
install(FILES ${DWCGF_YAML} DESTINATION "${GW_SAMPLE_BINARY_DESTINATION}")
install(FILES ${DWCGF_STM} DESTINATION "${GW_SAMPLE_BINARY_DESTINATION}")
install(DIRECTORY ${DWCGF_GRAPHS_DIR} DESTINATION ${SDK_GRAPHS_DESTINATION})
# todo: 自动删去scheme的那一行，再拷贝过去
install(DIRECTORY ${DWCGF_DATA_DIR} DESTINATION ${SDK_DATA_DESTINATION})
install(PROGRAMS
    ${DWCGF_RUNNER} ${DWCGF_RIG_TESTER}
    DESTINATION "${GW_SAMPLE_BINARY_DESTINATION}"
)

ament_package()
