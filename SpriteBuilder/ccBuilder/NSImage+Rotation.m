//
//  NSImage+Rotation.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-06-20.
//  Adapted from https://github.com/jerrykrinock/CategoriesObjC/blob/master/NSImage+Transform.m
//

#import "NSImage+Rotation.h"

@implementation NSImage (Rotation)

- (NSImage *)imageRotatedByRadians:(CGFloat)rotationInRadians {
    if (rotationInRadians == 0 || isnan(rotationInRadians)) return self;
    
    // Calculate the bounds for the rotated image
    // We do this by affine-transforming the bounds rectangle
    NSRect imageBounds = NSMakeRect(0, 0, self.size.width, self.size.height);
    NSBezierPath *boundsPath = [NSBezierPath bezierPathWithRect:imageBounds];
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform rotateByRadians:rotationInRadians];
    [boundsPath transformUsingAffineTransform:transform];
    NSRect rotatedBounds = NSMakeRect(0, 0, NSWidth(boundsPath.bounds), NSHeight(boundsPath.bounds));
    NSImage *rotatedImage = [[NSImage alloc] initWithSize:rotatedBounds.size];
    
    // Center the image within the rotated bounds
    imageBounds.origin.x = NSMidX(rotatedBounds) - (NSWidth(imageBounds) / 2);
    imageBounds.origin.y = NSMidY(rotatedBounds) - (NSHeight(imageBounds) / 2);
    
    // Start a new transform, to transform the image
    transform = [NSAffineTransform transform];
    
    // Move coordinate system to the center
    // (since we want to rotate around the center)
    [transform translateXBy:+(NSWidth(rotatedBounds) / 2) yBy:+(NSHeight(rotatedBounds) / 2)];
    // Do the rotation
    [transform rotateByRadians:rotationInRadians];
    // Move coordinate system back to normal (bottom, left)
    [transform translateXBy:-(NSWidth(rotatedBounds) / 2) yBy:-(NSHeight(rotatedBounds) / 2)];
    
    // Draw the original image, rotated, into the new image
    // Note: This "drawing" is done off-screen.
    [rotatedImage lockFocus];
    [transform concat];
    [self drawInRect:imageBounds fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
    [rotatedImage unlockFocus];
    
    return rotatedImage;
}

@end