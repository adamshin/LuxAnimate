//
//  JXLDecoderShim.h
//

#import <Foundation/Foundation.h>

@interface JXLDecoderShimOutput: NSObject

@property (nonatomic, strong) NSData *data;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
    
@end

@interface JXLDecoderShim: NSObject

+ (JXLDecoderShimOutput *)decodeImageFromData:(NSData *)inputData;

@end
