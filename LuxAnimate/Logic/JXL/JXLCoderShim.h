//
//  JXLCoderShim.h
//

#import <Foundation/Foundation.h>

@interface JXLCoderShim: NSObject

+ (NSData *)encodeImageWithData:(NSData *)imageData
                          width:(NSInteger)width
                         height:(NSInteger)height
                       lossless:(BOOL)lossless
                        quality:(NSInteger)quality
                         effort:(NSInteger)effort;

@end
