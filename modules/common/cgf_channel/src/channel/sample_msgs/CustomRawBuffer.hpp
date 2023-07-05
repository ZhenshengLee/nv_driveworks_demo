#ifndef CHANNEL_PACKET_TYPES_SAMPLE_CUSTOM_RAW_BUFFER_HPP
#define CHANNEL_PACKET_TYPES_SAMPLE_CUSTOM_RAW_BUFFER_HPP

#include <dw/core/base/Types.h>
#include <dwcgf/channel/ChannelPacketTypes.hpp>

// Enumerate types of memory for raw buffer
enum MemoryType
{
    CPU,
    CUDA
};

/**
 * @brief CustomRawBuffer is a simple header that points to a contiguous chunk of memory.
 *
 */
struct CustomRawBuffer
{
    dwTime_t timestamp;
    /**
     * if memoryType = CPU, buffer is a host pointer and if memoryType = CUDA, buffer is device pointer.
     */
    MemoryType memoryType;
    /**
     * The pointer to the raw buffer memory
     */
    void* buffer;
    /**
     * The capacity in bytes of the raw buffer memory
     */
    size_t capacity;
    /**
     * The current size of this buffer.
     */
    size_t size;
};

/**
 * @brief Declare the ChannelPacketTypeID for CustomRawBuffer
 *
 * This declaration should not be in the range of ids that will be taken by CGF. Defining it equal to
 * DWFRAMEWORK_MAX_INTERNAL_TYPES ensures thatit won't conflict. In order to manage all the type IDs it is
 * recommended to group all the declarations into an enum. However, as this sample is only defining a sinlge
 * type the enum is not needed.
 */
constexpr dw::framework::ChannelPacketTypeID CustomRawBufferTypeID = dw::framework::DWFRAMEWORK_MAX_INTERNAL_TYPES;

/**
 * Declare CustomRawBuffer as a non-POD type, with SpecimenType CustomRawBuffer meaning that it will be expected that
 * the application pass a CustomRawBuffer as a specimen to be able to allocate CustomRawBuffer. When used as a specimen,
 * CustomRawBuffer::buffer will be ignored. CustomRawBuffer::memoryType and CustomRawBuffer::size will be used to know how much
 * and what kind of memory to allocate.
 */
DWFRAMEWORK_DECLARE_PACKET_TYPE_RELATION(CustomRawBuffer, CustomRawBuffer, CustomRawBufferTypeID);

#endif // CHANNEL_PACKET_TYPES_SAMPLE_CUSTOM_RAW_BUFFER_HPP