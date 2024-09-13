//
//  JXLDecoderShim.m
//

#import "JXLDecoderShim.h"

#import <jxl/decode_cxx.h>
#import <jxl/resizable_parallel_runner_cxx.h>

#import <vector>

// MARK: - JXLDecoderShimOutput

@implementation JXLDecoderShimOutput

- (nonnull instancetype)init
{
    self = [super init];
    if (self) {
        _pixelData = [[NSData alloc] init];
        _width = 0;
        _height = 0;
    }
    return self;
}

@end

// MARK: - JXLDecoderShim

@interface JXLDecoderShim () {
    JxlPixelFormat _format;
    JxlDecoderPtr _decoder;
    JxlResizableParallelRunnerPtr _runner;
}

@end

@implementation JXLDecoderShim

- (nullable instancetype)initWithInputData:(nonnull NSData *)inputData
{
    self = [super init];
    if (self) {
        _output = [[JXLDecoderShimOutput alloc] init];
        
        _format = {
            .num_channels = 4,
            .data_type = JXL_TYPE_UINT8,
            .endianness = JXL_NATIVE_ENDIAN,
            .align = 0
        };
        
        _decoder = JxlDecoderMake(nullptr);
        _runner = JxlResizableParallelRunnerMake(nullptr);
        
        if (JXL_DEC_SUCCESS != JxlDecoderSubscribeEvents(
            _decoder.get(),
            JXL_DEC_BASIC_INFO |
            JXL_DEC_FULL_IMAGE)
        ) {
            return NULL;
        }
        
        if (JXL_DEC_SUCCESS != JxlDecoderSetParallelRunner(
            _decoder.get(),
            JxlResizableParallelRunner,
            _runner.get())
        ) {
            return NULL;
        }
        
        if (JXL_DEC_SUCCESS != JxlDecoderSetUnpremultiplyAlpha(
            _decoder.get(),
            JXL_TRUE)
        ) {
            return NULL;
        }
        
        JxlDecoderSetInput(
            _decoder.get(),
            (uint8_t *)inputData.bytes,
            (size_t)inputData.length);
        
        JxlDecoderCloseInput(_decoder.get());
    }
    return self;
}

- (JXLDecoderProcessResult)process
{
    auto status = JxlDecoderProcessInput(_decoder.get());
    
    if (status == JXL_DEC_SUCCESS) {
        return JXLDecoderProcessResultSuccess;
        
    } else if (status == JXL_DEC_ERROR) {
        return JXLDecoderProcessResultFailure;
        
    } else if (status == JXL_DEC_NEED_MORE_INPUT) {
        return JXLDecoderProcessResultFailure;
        
    } else if (status == JXL_DEC_BASIC_INFO) {
        JxlBasicInfo info;
        if (JXL_DEC_SUCCESS != JxlDecoderGetBasicInfo(
            _decoder.get(),
            &info)
        ) {
            return JXLDecoderProcessResultFailure;
        }
        
        auto threadCount = JxlResizableParallelRunnerSuggestThreads(
            info.xsize,
            info.ysize);
        
        JxlResizableParallelRunnerSetThreads(
            _runner.get(),
            threadCount);
        
        _output.width = info.xsize;
        _output.height = info.ysize;
        
        return JXLDecoderProcessResultContinue;
        
    } else if (status == JXL_DEC_NEED_IMAGE_OUT_BUFFER) {
        size_t bufferSize;
        if (JXL_DEC_SUCCESS != JxlDecoderImageOutBufferSize(
            _decoder.get(),
            &_format,
            &bufferSize)
        ) {
            return JXLDecoderProcessResultFailure;
        }
        
        _output.pixelData = [[NSMutableData alloc] initWithLength:bufferSize];
        
        if (JXL_DEC_SUCCESS !=
            JxlDecoderSetImageOutBuffer(
                _decoder.get(),
                &_format,
                (void *)_output.pixelData.bytes,
                bufferSize)
        ) {
            return JXLDecoderProcessResultFailure;
        }
        return JXLDecoderProcessResultContinue;
        
    } else if (status == JXL_DEC_FULL_IMAGE) {
        return JXLDecoderProcessResultContinue;
        
    } else {
        return JXLDecoderProcessResultFailure;
    }
}

@end
