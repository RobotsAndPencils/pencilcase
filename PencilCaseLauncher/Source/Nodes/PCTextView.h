//
//  PCTextView.h
//  PCPlayer
//
//  Created by Cody Rayment on 2/3/2014.
//  Copyright (c) 2012 Robots and Pencils Inc. All rights reserved.
//

#import "PCOverlayNode.h"

@interface PCTextView : SKSpriteNode <PCOverlayNode>

@property (copy, nonatomic) NSString *rtfContent;
@property (copy, nonatomic) NSString *string;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) NSAttributedString *contentAttributedString;

@end
