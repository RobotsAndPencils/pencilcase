//
//  PCTokenBrowsePlaceholder.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-09-19.
//
//

#import <Cocoa/Cocoa.h>
#import "PCTokenBrowsable.h"

@interface PCBrowseTokenPlaceholder : NSObject <PCTokenBrowsable>

@property (copy, nonatomic) NSString *browseDisplayName;
@property (strong, nonatomic) NSArray *browseChildren;
@property (assign, nonatomic, getter=isSelectable) BOOL selectable;

@end
