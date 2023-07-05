#ifndef SAMPLES_COMMON_TYPECALLBACKS_HPP_
#define SAMPLES_COMMON_TYPECALLBACKS_HPP_

// Define simple template for handling the supported data types
// of this sample app, either IntWithTimestamp, dwImage, or CustomRawPacket.
// That way the main app class can be re-used for each of the data types.
template <typename PacketT>
struct TypeCallbacks;

// TypeCallbacks的本质是一种类型萃取
// 参考EffectiveCpp3rd, 模板元编程
template <>
struct TypeCallbacks<IntWithTimestamp>
{
    static IntWithTimestamp getSpecimen()
    {
        return {};
    }

    static size_t getSize()
    {
        return sizeof(IntWithTimestamp);
    }

    static dwTime_t getTimestamp(IntWithTimestamp data)
    {
        return data.timestamp;
    }

    static void setTimestamp(IntWithTimestamp& data, dwTime_t time)
    {
        data.timestamp = time;
    }
};

template <>
struct TypeCallbacks<dwImageHandle_t>
{
    static constexpr size_t IMAGE_WIDTH = 3860;
    static constexpr size_t IMAGE_HEIGHT = 2160;

    static dwImageProperties getSpecimen()
    {
        // This can be changed to change the parameters of the images to
        // be streamed.
        dwImageProperties prop{ .type = DW_IMAGE_CUDA,
                                .width = IMAGE_WIDTH,
                                .height = IMAGE_HEIGHT,
                                .format = DW_IMAGE_FORMAT_YUV420_UINT8_PLANAR };
        prop.memoryLayout = DW_IMAGE_MEMORY_TYPE_PITCH;

        return prop;
    }

    static size_t getSize()
    {
        auto prop = getSpecimen();
        size_t elementSize = 0;
        size_t planeCount = 0;

        uint32_t planeChannelCount[DW_MAX_IMAGE_PLANES] = { 0 };
        dwVector2ui planeSize[DW_MAX_IMAGE_PLANES] = { 0 };

        size_t imageSize = 0;

        CHECK_DW_ERROR(dwImage_getDataLayout(&elementSize, &planeCount, planeChannelCount, planeSize, &prop));

        for (size_t i = 0; i < planeCount; i++)
        {
            imageSize += elementSize * planeSize[i].x * planeChannelCount[i] * planeSize[i].y;
        }

        return imageSize;
    }

    static dwTime_t getTimestamp(dwImageHandle_t img)
    {
        dwTime_t packetTime;
        CHECK_DW_ERROR(dwImage_getTimestamp(&packetTime, img));
        return packetTime;
    }

    static void setTimestamp(dwImageHandle_t img, dwTime_t time)
    {
        CHECK_DW_ERROR(dwImage_setTimestamp(time, img));
    }
};

template <>
struct TypeCallbacks<CustomRawBuffer>
{
    static CustomRawBuffer getSpecimen()
    {
        // This can be changed to change the properties of the CustomRawBuffer being streamed.
        CustomRawBuffer specimen{};
        specimen.capacity = 256;
        specimen.memoryType = MemoryType::CPU;
        return specimen;
    }

    static size_t getSize()
    {
        return sizeof(CustomRawBuffer);
    }

    static dwTime_t getTimestamp(CustomRawBuffer& data)
    {
        return data.timestamp;
    }

    static void setTimestamp(CustomRawBuffer& data, dwTime_t time)
    {
        data.timestamp = time;
    }
};

#endif // SAMPLES_COMMON_TYPECALLBACKS_HPP_
