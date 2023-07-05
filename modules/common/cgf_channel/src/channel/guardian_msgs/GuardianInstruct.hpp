#ifndef CHANNEL_PACKET_TYPES_GUARDIAN_GUARDIAN_INSTRUCT_HPP_
#define CHANNEL_PACKET_TYPES_GUARDIAN_GUARDIAN_INSTRUCT_HPP_

#include <dwcgf/channel/ChannelPacketTypes.hpp>
#include <channel/common/AvEnums.hpp>

// c struct
#ifdef __cplusplus
extern "C" {
#endif

typedef enum gwInstruct
{
    UNKNOWN = 0,
    MANUAL = 1,
    STANDBY = 2,
    ERROR = 3,
    APA_INIT = 4,
    APA_ACTIVE = 5,
    PILOT_INIT = 6,
    PILOT_ACTIVE = 7,
    PILOT_APA_READY = 8,
    PILOT_PRE_APA = 9,
} gwInstruct;

typedef struct gwGuardianInstruct
{
    /// Timestamp of the message when first received [usec].
    dwTime_t timestamp_us;
    /// GuardianInstruct
    gwInstruct instruct;
} gwGuardianInstruct;

#ifdef __cplusplus
}
#endif

// here declare node init output port parameters
DWFRAMEWORK_DECLARE_PACKET_TYPE_POD(gwGuardianInstruct);

#endif  // CHANNEL_PACKET_TYPES_GUARDIAN_GUARDIAN_INSTRUCT_HPP_