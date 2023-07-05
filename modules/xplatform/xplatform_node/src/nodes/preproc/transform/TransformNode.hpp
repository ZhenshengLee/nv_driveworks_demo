#ifndef TRANSFORM_NODE_HPP_
#define TRANSFORM_NODE_HPP_

#include <string>

#include <dwcgf/channel/Channel.hpp>
#include <dwcgf/node/Node.hpp>
#include <dwcgf/pass/Pass.hpp>
#include <dwcgf/pass/PassDescriptor.hpp>
#include <dwcgf/port/Port.hpp>
#include <dwcgf/port/PortDescriptor.hpp>
#include <dwcgf/parameter/ParameterDescriptor.hpp>

// custom dwchannel type
#include "channel/guardian_msgs/GuardianInstruct.hpp"
#include "channel/sample_msgs/CustomRawBuffer.hpp"

namespace dw
{
namespace framework
{

struct gwTransformNodeParams
{
    cudaStream_t cudaStream;
};

class gwTransformNode : public ExceptionSafeProcessNode
{
public:
    static constexpr auto describeInputPorts()
    {
        using namespace dw::framework;
        return describePortCollection(DW_DESCRIBE_PORT(int, "VALUE_IN"_sv, PortBinding::REQUIRED));
    };
    static constexpr auto describeOutputPorts()
    {
        using namespace dw::framework;
        return describePortCollection(DW_DESCRIBE_PORT(int, "VALUE_OUT"_sv, PortBinding::REQUIRED));
    };

    static constexpr auto describePasses()
    {
        return describePassCollection(
            describePass("SETUP"_sv, DW_PROCESSOR_TYPE_CPU),
            describePass("PROCESS"_sv, DW_PROCESSOR_TYPE_GPU),
            describePass("TEARDOWN"_sv, DW_PROCESSOR_TYPE_CPU));
    }

    static constexpr auto describeParameters()
    {
        return describeConstructorArguments<gwTransformNodeParams, dwContextHandle_t>(
            describeConstructorArgument(
                DW_DESCRIBE_INDEX_PARAMETER(cudaStream_t, "streamIndex"_sv, &gwTransformNodeParams::cudaStream)),
            describeConstructorArgument(DW_DESCRIBE_UNNAMED_PARAMETER(dwContextHandle_t)));
    }

    static std::unique_ptr<gwTransformNode> create(ParameterProvider& provider);

    gwTransformNode(const gwTransformNodeParams& params, const dwContextHandle_t ctx);
};

} // namespace framework
} // namespace dw

#endif // TRANSFORM_NODE_HPP_
