project(common_cgf_channel C CXX)

include(GWModuleInstallConfig)

set(DRIVEWORKS_PATH "/usr/local/driveworks")
set(DWCGF_CHANNEL_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src/channel)
set(GW_HEADER_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)
set(DW_CHANNEL_SAMPLE ${CMAKE_CURRENT_SOURCE_DIR}/bin/sample_cgf_dwchannel)
set(DW_NVSTREAM_EVENT_SAMPLE ${CMAKE_CURRENT_SOURCE_DIR}/bin/nvscistream_event_sample)
set(DW_NVSTREAM_PERF_SAMPLE ${CMAKE_CURRENT_SOURCE_DIR}/bin/test_nvscistream_perf)

file(GLOB_RECURSE DWCGF_CHANNEL_FILES
    ${DWCGF_CHANNEL_DIR}/*.hpp
    ${DWCGF_CHANNEL_DIR}/*.cpp
)

if (NOT TARGET driveworks-shared)
    find_package(driveworks-shared REQUIRED CONFIG HINTS ${DRIVEWORKS_PATH}/cmake)
endif()

if (NOT TARGET dwframework)
    find_package(dwframework REQUIRED CONFIG HINTS ${DRIVEWORKS_PATH}/cmake)
endif()

find_package(NvSCI MODULE REQUIRED COMPONENTS NvSciSync)

set(LIBRARIES
    ${Driveworks_LIBRARIES}
    driveworks-shared
    dwframework
    NvSCI::NvSciSync
)

#-------------------------------------------------------------------------------
# channel shared library
#-------------------------------------------------------------------------------
add_library(${PROJECT_NAME} STATIC ${DWCGF_CHANNEL_FILES})
set_target_properties(${PROJECT_NAME} PROPERTIES LINKER_LANGUAGE CXX)
target_link_libraries(${PROJECT_NAME} PRIVATE ${LIBRARIES})
target_include_directories(${PROJECT_NAME}
                           PUBLIC
                           ${CUDA_DIR}/include
                           ${DW_ROOT}/include
                           ${DW_ROOT}/include/3rdparty
                           ${DW_ROOT}/include/dwshared/dwfoundation
                           ${DW_ROOT}/include/dwshared/dwtrace)

set_target_properties(${PROJECT_NAME} PROPERTIES
    HEADER_DIR ${GW_HEADER_DIR}
)

#-------------------------------------------------------------------------------
# tools
#-------------------------------------------------------------------------------
add_executable(dwchannel_test
    ./tools/dwchannel_test.cpp
    ./tools/ProgramArguments.cpp
    ./tools/Log.cpp
    # must add src with custom.cpp
    ${DWCGF_CHANNEL_FILES}
)
target_link_libraries(dwchannel_test PRIVATE ${LIBRARIES})
target_include_directories(dwchannel_test
                           PUBLIC
                           ./tools/
                           ${GW_HEADER_DIR}
                           ${CUDA_DIR}/include
                           ${DW_ROOT}/include
                           ${DW_ROOT}/include/3rdparty
                           ${DW_ROOT}/include/dwshared/dwfoundation
                           ${DW_ROOT}/include/dwshared/dwtrace)
gw_add_module(dwchannel_test)

install(PROGRAMS
    ${DW_CHANNEL_SAMPLE} ${DW_NVSTREAM_EVENT_SAMPLE} ${DW_NVSTREAM_PERF_SAMPLE}
    DESTINATION "${GW_MODULE_BINARY_DESTINATION}"
)
