//
//  PCResourceLibrary.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-06-26.
//
//

@import SpriteKit;

#import <Foundation/Foundation.h>

@class PCResource;

///Handles managing + loading PC resources
@interface PCResourceLibrary : NSObject

+ (nonnull PCResourceLibrary *)sharedLibrary;

- (nullable SKTexture *)textureForResource:(nonnull PCResource *)resource;

- (void)clearLibrary;

@end
