#ifndef CHANNEL_PACKET_TYPES_STD_STRING_HPP_
#define CHANNEL_PACKET_TYPES_STD_STRING_HPP_

#include <dwcgf/channel/ChannelPacketTypes.hpp>

#include <channel/common/AvEnums.hpp>

typedef dw::core::FixedString<32> string32_t;
typedef dw::core::FixedString<64> string64_t;
typedef dw::core::FixedString<128> string128_t;
typedef dw::core::FixedString<256> string256_t;
typedef dw::core::FixedString<512> string512_t;

DWFRAMEWORK_DECLARE_PACKET_TYPE_POD(string32_t);
DWFRAMEWORK_DECLARE_PACKET_TYPE_POD(string64_t);
DWFRAMEWORK_DECLARE_PACKET_TYPE_POD(string128_t);
DWFRAMEWORK_DECLARE_PACKET_TYPE_POD(string256_t);
DWFRAMEWORK_DECLARE_PACKET_TYPE_POD(string512_t);

#endif  // CHANNEL_PACKET_TYPES_STD_STRING_HPP_
