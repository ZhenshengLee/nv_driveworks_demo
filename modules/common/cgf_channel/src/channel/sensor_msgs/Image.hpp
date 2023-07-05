#ifndef CHANNEL_PACKET_TYPES_SENSOR_IMAGE_HPP_
#define CHANNEL_PACKET_TYPES_SENSOR_IMAGE_HPP_

#include <dw/image/Image.h>
#include <dwcgf/channel/ChannelPacketTypes.hpp>

#include <channel/common/AvEnums.hpp>

// here declare node init output port parameters
DWFRAMEWORK_DECLARE_PACKET_DWTYPE_RELATION(dwImageHandle_t, dwImageProperties, DW_IMAGE_HANDLE);
DWFRAMEWORK_DECLARE_PACKET_TYPE_POD(dwImageHandle_t*);

#endif  // CHANNEL_PACKET_TYPES_SENSOR_IMAGE_HPP_