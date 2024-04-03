//
//  JXLDecoderShim.m
//

#import "JXLDecoderShim.h"

#import <jxl/decode_cxx.h>
#import <jxl/resizable_parallel_runner_cxx.h>

#import <vector>

@implementation JXLDecoderShimOutput

- (id)init
{
    self = [super init];
    self.data = [[NSData alloc] init];
    self.width = 0;
    self.height = 0;
    
    return self;
}

@end

@implementation JXLDecoderShim

+ (JXLDecoderShimOutput *)decodeImageFromData:(NSData *)inputData
{
    auto runner = JxlResizableParallelRunnerMake(nullptr);
    auto dec = JxlDecoderMake(nullptr);
    
    if (JXL_DEC_SUCCESS != JxlDecoderSubscribeEvents(
        dec.get(),
        JXL_DEC_BASIC_INFO |
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
    
    if (JXL_DEC_SUCCESS != JxlDecoderSetUnpremultiplyAlpha(
        dec.get(),
        JXL_TRUE)
    ) {
        return NULL;
    }
    
    JxlBasicInfo info;
    JxlPixelFormat format = {
        4,
        JXL_TYPE_UINT8,
        JXL_BIG_ENDIAN,
        0
    };
    
    JxlDecoderSetInput(
        dec.get(),
        (uint8_t *)inputData.bytes,
        (size_t)inputData.length);
    
    JxlDecoderCloseInput(dec.get());
    
    JXLDecoderShimOutput *output = [[JXLDecoderShimOutput alloc] init];
    
    while (true) {
        JxlDecoderStatus status = JxlDecoderProcessInput(dec.get());
        
        if (status == JXL_DEC_SUCCESS) {
            return output;
            
        } else if (status == JXL_DEC_ERROR) {
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
            
        } else {
            fprintf(stderr, "Unknown decoder status\n");
            return NULL;
        }
    }
}

@end
