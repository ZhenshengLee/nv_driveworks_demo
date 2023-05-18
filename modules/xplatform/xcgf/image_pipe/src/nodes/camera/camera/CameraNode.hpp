#ifndef CAMERA_NODE_HPP_
#define CAMERA_NODE_HPP_

#include <string>

// dwmodule
#include <dw/rig/Rig.h>
#include <dw/sensors/Sensors.h>
#include <dw/sensors/camera/Camera.h>
// dwcgf framework
#include <dwcgf/channel/Channel.hpp>
#include <dwcgf/node/Node.hpp>
#include <dwcgf/parameter/ParameterDescriptor.hpp>
#include <dwcgf/parameter/SemanticParameterTypes.hpp>
#include <dwcgf/pass/Pass.hpp>
#include <dwcgf/pass/PassDescriptor.hpp>
#include <dwcgf/port/Port.hpp>
#include <dwcgf/port/PortDescriptor.hpp>
// custom dwchannel type
#include "channel/Image.hpp"
#include "channel/GuardianInstruct.hpp"
#include "channel/CustomRawBuffer.hpp"
// custom parameter
#include "parameter/CameraTypes.hpp"

namespace dw
{
namespace framework
{

class gwCameraNodeImpl;

struct gwCameraNodeParams
{
    size_t cameraIndex;
    size_t salStartIndex;
    gwCameraType cameraType;
    dw::core::FixedString<256> cameraParameter;
    dw::core::FixedString<256> cameraProtocol;
    dw::core::FixedString<256> cameraIntrinsics;
};

struct gwCameraNodeRuntimeParams
{
    dwConstRigHandle_t rig;
    dwSALHandle_t sal;
    // cudaStream_t cudaStream;
};

class gwCameraNode : public ExceptionSafeSensorNode
{
  public:
    static constexpr auto describeInputPorts()
    {
        using namespace dw::framework;
        return describePortCollection();
    };
    static constexpr auto describeOutputPorts()
    {
        using namespace dw::framework;
        return describePortCollection(DW_DESCRIBE_PORT(dwImageHandle_t, "IMAGE_PROCESSED_YUV"_sv),
                                      DW_DESCRIBE_PORT(dwTime_t, "IMAGE_TIMESTAMP"_sv),
                                      DW_DESCRIBE_PORT(int, "VALUE_0"_sv),
                                      DW_DESCRIBE_PORT(gwGuardianInstruct, "GUARDIAN_INSTRUCT"_sv));
    };

    static constexpr auto describePasses()
    {
        return describePassCollection(describePass("SETUP"_sv, DW_PROCESSOR_TYPE_CPU),
                                      describePass("PROCESSED_OUTPUT"_sv, DW_PROCESSOR_TYPE_CPU),
                                      describePass("TEARDOWN"_sv, DW_PROCESSOR_TYPE_CPU));
    }

    dwSensorType getSensorType() const
    {
        return DW_SENSOR_CAMERA;
    }

    static std::unique_ptr<gwCameraNode> create(ParameterProvider& provider);

    static constexpr auto describeParameters()
    {
        // file:///E:/orin_ws/nv_driveworks/driverorks-5.10/doc/nvcgf_html/cgf_tutorials_node.html
        return describeConstructorArguments<gwCameraNodeParams, gwCameraNodeRuntimeParams, dwContextHandle_t>(
            describeConstructorArgument(
                DW_DESCRIBE_PARAMETER(size_t, "cameraIndex"_sv, &gwCameraNodeParams::cameraIndex),
                DW_DESCRIBE_PARAMETER(size_t, "salStartIndex"_sv, &gwCameraNodeParams::salStartIndex),
                DW_DESCRIBE_PARAMETER(gwCameraType, "cameraType"_sv, &gwCameraNodeParams::cameraType),
                DW_DESCRIBE_PARAMETER(dw::core::FixedString<256>, "cameraParameter"_sv,
                                      &gwCameraNodeParams::cameraParameter),
                DW_DESCRIBE_PARAMETER(dw::core::FixedString<256>, "cameraProtocol"_sv,
                                      &gwCameraNodeParams::cameraProtocol),
                DW_DESCRIBE_PARAMETER(dw::core::FixedString<256>, "cameraIntrinsics"_sv,
                                      &gwCameraNodeParams::cameraIntrinsics)),
            describeConstructorArgument(
                DW_DESCRIBE_UNNAMED_PARAMETER(dwConstRigHandle_t, &gwCameraNodeRuntimeParams::rig),
                DW_DESCRIBE_UNNAMED_PARAMETER(dwSALHandle_t, &gwCameraNodeRuntimeParams::sal)),
            describeConstructorArgument(DW_DESCRIBE_UNNAMED_PARAMETER(dwContextHandle_t)));
    }

    gwCameraNode(const gwCameraNodeParams& params, const gwCameraNodeRuntimeParams& runtimeParams, const dwContextHandle_t ctx);

    // constructors with dwSensorParams
    // gwCameraNode(const dwSensorParams& params, cudaStream_t cudaStream, dwSALHandle_t sal, dwContextHandle_t ctx);
    // gwCameraNode(const char* sensorName, dwConstRigHandle_t rigHandle, dwSALHandle_t sal, dwContextHandle_t ctx,
    //              const FixedString<32>& frameSkipMask);
    // gwCameraNode(const dwSensorParams& params, dwSALHandle_t sal, dwContextHandle_t ctx);
};

}  // namespace framework
}  // namespace dw

#endif  // CAMERA_NODE_HPP_
