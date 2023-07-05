#ifndef CHANNEL_PACKET_TYPES_SAMPLE_INTWITHTIMESTAMP_HPP_
#define CHANNEL_PACKET_TYPES_SAMPLE_INTWITHTIMESTAMP_HPP_

#include <dwcgf/channel/ChannelPacketTypes.hpp>

#include <channel/common/AvEnums.hpp>

struct IntWithTimestamp
{
    int count;
    dwTime_t timestamp;
};

DWFRAMEWORK_DECLARE_PACKET_TYPE_POD(IntWithTimestamp);

#endif  // CHANNEL_PACKET_TYPES_SAMPLE_INTWITHTIMESTAMP_HPP_

