//
//  NSImage+ProportionalScaling.h
//  SpriteBuilder
//
//  Created by Brandon on 2014-03-17.
//
//

#import <Cocoa/Cocoa.h>

@interface NSImage (ProportionalScaling)

- (NSImage*)imageByScalingProportionallyToSize:(NSSize)targetSize;

@end
