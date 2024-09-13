//
//  JXLDecoderShim.h
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JXLDecoderProcessResult) {
    JXLDecoderProcessResultContinue,
    JXLDecoderProcessResultSuccess,
    JXLDecoderProcessResultFailure
};

@interface JXLDecoderShimOutput: NSObject

@property (nonatomic, strong, nonnull) NSData *pixelData;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;

- (nonnull instancetype)init;
    
@end

@interface JXLDecoderShim: NSObject

@property (nonatomic, strong, nonnull) JXLDecoderShimOutput *output;

- (nullable instancetype)initWithInputData:(nonnull NSData *)inputData;

- (JXLDecoderProcessResult)process;

@end
