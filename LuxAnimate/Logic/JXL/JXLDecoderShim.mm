//
//  JXLDecoderShim.m
//

#import "JXLDecoderShim.h"

#import <jxl/decode_cxx.h>
#import <jxl/resizable_parallel_runner_cxx.h>

#import <vector>

@implementation JXLDecoderShimOutput
@end

@implementation JXLDecoderShim

+ (JXLDecoderShimOutput *)decodeImageFromData:(NSData *)inputData
{
    auto runner = JxlResizableParallelRunnerMake(nullptr);
    auto dec = JxlDecoderMake(nullptr);
    
    if (JXL_DEC_SUCCESS != JxlDecoderSubscribeEvents(
        dec.get(),
        JXL_DEC_BASIC_INFO |
//        JXL_DEC_COLOR_ENCODING |
        JXL_DEC_FULL_IMAGE)
    ) {
        return NULL;
    }
    
    if (JXL_DEC_SUCCESS != JxlDecoderSetParallelRunner(
        dec.get(),
        JxlResizableParallelRunner,
        runner.get())
    ) {
        return NULL;
    }
    
    JxlBasicInfo info;
    JxlPixelFormat format = {
        4,
        JXL_TYPE_FLOAT,
        JXL_NATIVE_ENDIAN,
        0
    };
    
    JxlDecoderSetInput(
        dec.get(),
        (uint8_t *)inputData.bytes,
        (size_t)inputData.length);
    
    JxlDecoderCloseInput(dec.get());
    
    JXLDecoderShimOutput *output = [[JXLDecoderShimOutput alloc] init];
    
    for (;;) {
        JxlDecoderStatus status = JxlDecoderProcessInput(dec.get());
        
        if (status == JXL_DEC_ERROR) {
            fprintf(stderr, "Decoder error\n");
            return NULL;
            
        } else if (status == JXL_DEC_NEED_MORE_INPUT) {
            fprintf(stderr, "Error, already provided all input\n");
            return NULL;
            
        } else if (status == JXL_DEC_BASIC_INFO) {
            if (JXL_DEC_SUCCESS != JxlDecoderGetBasicInfo(dec.get(), &info)) {
                fprintf(stderr, "JxlDecoderGetBasicInfo failed\n");
                return NULL;
            }
            
            JxlResizableParallelRunnerSetThreads(
                runner.get(),
                JxlResizableParallelRunnerSuggestThreads(
                    info.xsize,
                    info.ysize));
            
            output.width = info.xsize;
            output.height = info.ysize;
            
            // Don't care about color profile. Assuming sRGB
            
//        } else if (status == JXL_DEC_COLOR_ENCODING) {
//            size_t icc_size;
//            if (JXL_DEC_SUCCESS != JxlDecoderGetICCProfileSize(
//                dec.get(), 
//                JXL_COLOR_PROFILE_TARGET_DATA,
//                &icc_size)
//            ) {
//                fprintf(stderr, "JxlDecoderGetICCProfileSize failed\n");
//                return false;
//            }
//            icc_profile->resize(icc_size);
//            if (JXL_DEC_SUCCESS != JxlDecoderGetColorAsICCProfile(
//                                                                  dec.get(), JXL_COLOR_PROFILE_TARGET_DATA,
//                                                                  icc_profile->data(), icc_profile->size())) {
//                                                                      fprintf(stderr, "JxlDecoderGetColorAsICCProfile failed\n");
//                                                                      return false;
//                                                                  }
        } else if (status == JXL_DEC_NEED_IMAGE_OUT_BUFFER) {
            size_t bufferSize;
            if (JXL_DEC_SUCCESS !=
                JxlDecoderImageOutBufferSize(
                    dec.get(),
                    &format,
                    &bufferSize)
            ) {
                fprintf(stderr, "JxlDecoderImageOutBufferSize failed\n");
                return NULL;
            }
            
            output.data = [[NSMutableData alloc] initWithLength:bufferSize];
            
            if (JXL_DEC_SUCCESS !=
                JxlDecoderSetImageOutBuffer(
                    dec.get(),
                    &format,
                    (void *)output.data.bytes,
                    bufferSize)
            ) {
                fprintf(stderr, "JxlDecoderSetImageOutBuffer failed\n");
                return NULL;
            }
        } else if (status == JXL_DEC_FULL_IMAGE) {
            // Nothing to do. Do not yet return. If the image is an animation, more
            // full frames may be decoded. This example only keeps the last one.
        } else if (status == JXL_DEC_SUCCESS) {
            // All decoding successfully finished.
            // It's not required to call JxlDecoderReleaseInput(dec.get()) here since
            // the decoder will be destroyed.
            return output;
        } else {
            fprintf(stderr, "Unknown decoder status\n");
            return NULL;
        }
    }
}

@end
