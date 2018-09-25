//
//  InspectorTimelineRepeat.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-06-06.
//
//

#import "InspectorTimelineRepeat.h"
#import "PCSKVideoPlayer.h"


@interface InspectorTimelineRepeat ()

@property (nonatomic, weak) IBOutlet NSPopUpButton *repeatPopupButton;
@property (assign, nonatomic) PCTimelineRepeat timelineRepeat;

@end


@implementation InspectorTimelineRepeat

- (void)willBeAdded {
    [self.repeatPopupButton bind:@"selectedIndex" toObject:self withKeyPath:@"timelineRepeat" options:nil];
}

- (void)willBeRemoved {
    [self.repeatPopupButton unbind:@"selectedIndex"];
}

- (void)setTimelineRepeat:(PCTimelineRepeat)timelineRepeat {
    [self setPropertyForSelection:@(timelineRepeat)];
}

- (PCTimelineRepeat)timelineRepeat {
    PCSKVideoPlayer *videoNode = [self.selection.managedNodes objectAtIndex:0];
    return videoNode.timelineRepeat;
}

@end
