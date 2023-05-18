#ifndef CAMERA_NODE_IMPL_HPP_
#define CAMERA_NODE_IMPL_HPP_

#include "CameraNode.hpp"
#include <dwcgf/node/SimpleNodeT.hpp>

#include <dw/sensors/camera/Camera.h>
#include <dw/rig/Rig.h>

namespace dw
{
namespace framework
{

class gwCameraNodeImpl : public SimpleSensorNodeT<gwCameraNode>
{
  public:
    static constexpr char LOG_TAG[] = "gwCameraNode";
    using Base = SimpleSensorNodeT<gwCameraNode>;

    // Initialization and destruction
    gwCameraNodeImpl(const gwCameraNodeParams& params, const gwCameraNodeRuntimeParams& runtimeParams, const dwContextHandle_t ctx);
    ~gwCameraNodeImpl() override;

    // processnode
    dwStatus reset() final;

    // SimpleSensorNode
    dwStatus validate() final;
    dwStatus start() final;
    dwStatus stop() final;
    dwStatus isVirtual(bool*) final;
    dwStatus setDataEventReadCallback(DataEventReadCallback) final;
    dwStatus setDataEventWriteCallback(DataEventWriteCallback) final;
    // ISensorNode
    dwStatus setAffinityMask(uint) final;
    dwStatus setThreadPriority(int) final;
    dwStatus setStartTime(dwTime_t) final;
    dwStatus setEndTime(dwTime_t) final;
    dwStatus setLockstepDeterministicMode(bool enable) final;
    dwStatus getNextTimestamp(dwTime_t& nextTimestamp) final;

  private:
    // Passes functions
    dwStatus yuv_output();

    // node internal from cgf
    gwCameraNodeParams m_params{};

    // node internal from loaderlite-stm
    dwSALHandle_t m_sal{DW_NULL_HANDLE};
    dwConstRigHandle_t m_rig{ DW_NULL_HANDLE };
    dwContextHandle_t m_ctx{ DW_NULL_HANDLE };

    // node internal workload
    // workload: handle
    dwSensorHandle_t m_camera{DW_NULL_HANDLE};
    // workload: config
    dwSensorParams m_camera_param{};
    dwCameraOutputType m_image_type{DW_CAMERA_OUTPUT_CUDA_RGBA_UINT8};
    // workload: memory
    dwCameraFrameHandle_t m_camera_frame{ DW_NULL_HANDLE };
    dwImageHandle_t m_image_yuv{ DW_NULL_HANDLE };
    size_t m_epochCount{ 0 };
    gwGuardianInstruct m_guardian_instruct{};

};

}  // namespace framework
}  // namespace dw

#endif  // CAMERA_NODE_IMPL_HPP_
