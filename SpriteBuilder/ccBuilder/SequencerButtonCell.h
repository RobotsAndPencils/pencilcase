//
//  SequenerButtonCell.h
//  SpriteBuilder
//
//  Created by John Twigg on 2013-11-18.
//
//

#import <SpriteKit/SpriteKit.h>

@interface SequencerButtonCell : NSButtonCell {
    NSImage *imgRowBgChannel;
    BOOL imagesLoaded;
}

@property (nonatomic, weak) SKNode *node;

@end
