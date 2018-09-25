//
//  PCBrowseTokenEventVariable.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-09-19.
//
//

#import <Foundation/Foundation.h>
#import "PCTokenBrowsable.h"

@interface PCBrowseTokenEventVariable : NSObject <PCTokenBrowsable>

- (instancetype)initWithName:(NSString *)name;

@end
