//
//  NSImage+PNGRepresentation.m
//  SpriteBuilder
//
//  Created by Brandon on 2/12/2014.
//
//

#import "NSImage+PNGRepresentation.h"

@implementation NSImage (PNGRepresentation)

- (NSData *)PNGRepresentation {
    CGImageRef cgRef = [self CGImageForProposedRect:NULL context:nil hints:nil];
    NSBitmapImageRep *newRep = [[NSBitmapImageRep alloc] initWithCGImage:cgRef];
    [newRep setSize:[self size]];
    NSData *pngData = [newRep representationUsingType:NSPNGFileType properties:@{}];
    return pngData;
}

@end
