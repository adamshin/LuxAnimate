//
//  JXLDecoderShim.h
//

#import <Foundation/Foundation.h>

@interface JXLDecoderShimOutput: NSObject

@property (nonatomic, strong, nonnull) NSData *data;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;

- (id _Nonnull)init;
    
@end

@interface JXLDecoderShim: NSObject

+ (JXLDecoderShimOutput *_Nullable)decodeImageFromData:(NSData *_Nonnull)inputData;

@end
