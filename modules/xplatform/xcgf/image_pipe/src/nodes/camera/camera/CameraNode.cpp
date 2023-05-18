#include "CameraNode.hpp"
#include "CameraNodeImpl.hpp"

#include <dwcgf/parameter/ParameterProvider.hpp>

namespace dw
{
namespace framework
{

std::unique_ptr<gwCameraNode>
gwCameraNode::create(ParameterProvider& provider)
{
    // create is the sugar
    return dw::framework::create<gwCameraNode>(provider);
}

gwCameraNode::gwCameraNode(const gwCameraNodeParams& params, const gwCameraNodeRuntimeParams& runtimeParams,
                           const dwContextHandle_t ctx)
  : ExceptionSafeSensorNode(std::make_unique<gwCameraNodeImpl>(params, runtimeParams, ctx))
{
}

// 其他gwCameraNodeImpl

} // namespace framework
} // namespace dw

#include <dwcgf/node/NodeFactory.hpp>

DW_REGISTER_NODE(dw::framework::gwCameraNode)
