//
//  JXLEncoderShim.mm
//

#import "JXLEncoderShim.h"

#import <jxl/encode_cxx.h>
#import <jxl/resizable_parallel_runner_cxx.h>

#import <vector>

@implementation JXLEncoderShim

+ (NSData *)encodeImageWithData:(NSData *)imageData
                          width:(NSInteger)width
                         height:(NSInteger)height
                       lossless:(BOOL)lossless
                        quality:(NSInteger)quality
                         effort:(NSInteger)effort
{
    auto enc = JxlEncoderMake(nullptr);
    auto runner = JxlResizableParallelRunnerMake(nullptr);
    
    if (JXL_ENC_SUCCESS != JxlEncoderSetParallelRunner(
        enc.get(),
        JxlResizableParallelRunner,
        runner.get())
    ) {
        return NULL;
    }
    
    JxlResizableParallelRunnerSetThreads(
        runner.get(),
        JxlResizableParallelRunnerSuggestThreads(
            width,
            height));
    
    JxlPixelFormat pixelFormat = {
        4,
        JXL_TYPE_UINT8,
        JXL_BIG_ENDIAN,
        0
    };
    
    JxlBasicInfo basicInfo;
    JxlEncoderInitBasicInfo(&basicInfo);
    basicInfo.xsize = uint32_t(width);
    basicInfo.ysize = uint32_t(height);
    basicInfo.bits_per_sample = 8;
    basicInfo.uses_original_profile = lossless ? JXL_TRUE : JXL_FALSE;
    basicInfo.num_color_channels = 3;
    basicInfo.num_extra_channels = 1;
    
    if (JXL_ENC_SUCCESS != JxlEncoderSetBasicInfo(
        enc.get(),
        &basicInfo)
    ) {
        return NULL;
    }
    
    JxlExtraChannelInfo channelInfo;
    JxlEncoderInitExtraChannelInfo(JXL_CHANNEL_ALPHA, &channelInfo);
    channelInfo.bits_per_sample = 8;
    channelInfo.alpha_premultiplied = false;
    
    if (JXL_ENC_SUCCESS != JxlEncoderSetExtraChannelInfo(
        enc.get(),
        0,
        &channelInfo)
    ) {
        return NULL;
    }
    
    JxlColorEncoding color_encoding = {};
    JxlColorEncodingSetToSRGB(&color_encoding, JXL_FALSE);
    
    if (JXL_ENC_SUCCESS != JxlEncoderSetColorEncoding(
        enc.get(),
        &color_encoding)
    ) {
        return NULL;
    }
    
    auto frameSettings = JxlEncoderFrameSettingsCreate(
        enc.get(),
        nullptr);
    
    if (JXL_ENC_SUCCESS != JxlEncoderSetFrameLossless(
        frameSettings,
        lossless)
    ) {
        return NULL;
    }
    
    float distance = JxlEncoderDistanceFromQuality(float(quality));
    if (JXL_ENC_SUCCESS != JxlEncoderSetFrameDistance(
        frameSettings,
        distance)
    ) {
        return NULL;
    }
    
    if (JXL_ENC_SUCCESS != JxlEncoderFrameSettingsSetOption(
        frameSettings,
        JXL_ENC_FRAME_SETTING_EFFORT,
        effort)
    ) {
        return NULL;
    }
    
    if (JXL_ENC_SUCCESS != JxlEncoderAddImageFrame(
        frameSettings,
        &pixelFormat,
        imageData.bytes,
        imageData.length)
    ) {
        return NULL;
    }
    
    JxlEncoderCloseInput(enc.get());
    
    auto compressed = new std::vector<uint8_t>();
    compressed->resize(64);
    
    uint8_t* next_out = compressed->data();
    size_t avail_out = compressed->size() - (next_out - compressed->data());
    JxlEncoderStatus process_result = JXL_ENC_NEED_MORE_OUTPUT;
    
    while (process_result == JXL_ENC_NEED_MORE_OUTPUT) {
        process_result = JxlEncoderProcessOutput(enc.get(), &next_out, &avail_out);
        if (process_result == JXL_ENC_NEED_MORE_OUTPUT) {
            size_t offset = next_out - compressed->data();
            compressed->resize(compressed->size() * 2);
            next_out = compressed->data() + offset;
            avail_out = compressed->size() - offset;
        }
    }
    compressed->resize(next_out - compressed->data());
    
    if (JXL_ENC_SUCCESS != process_result) {
        delete compressed;
        return NULL;
    }

    auto data = [[NSData alloc] initWithBytesNoCopy:compressed->data()
                                             length:compressed->size()
    deallocator:^(void * _Nonnull bytes, NSUInteger length) {
        delete compressed;
    }];

    return data;
}

@end
