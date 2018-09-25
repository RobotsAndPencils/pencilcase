//
//  PCNodeChildrenManagement.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-09.
//
//

@protocol PCNodeChildInsertion <NSObject>

- (SKNode *)insertionNode;

@end

@protocol PCNodeChildExport <NSObject>

- (NSArray *)exportChildren;

@end