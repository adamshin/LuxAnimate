//
//  JXLEncoderShim.h
//

#import <Foundation/Foundation.h>

@interface JXLEncoderShim: NSObject

+ (NSData *)encodeImageWithData:(NSData *)imageData
                          width:(NSInteger)width
                         height:(NSInteger)height
                       lossless:(BOOL)lossless
                        quality:(NSInteger)quality
                         effort:(NSInteger)effort;

@end
