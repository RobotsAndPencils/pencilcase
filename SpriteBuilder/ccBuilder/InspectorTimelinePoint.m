//
//  InspectorTimelinePoint.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-05-29.
//
//

#import "InspectorTimelinePoint.h"

#import "PCMouseUpContinuousSlider.h"

static void *InspectorTimelinePointContext = &InspectorTimelinePointContext;


@interface InspectorTimelinePoint ()

@property (nonatomic, weak) IBOutlet NSTextField *timeField;
@property (nonatomic, weak) IBOutlet PCMouseUpContinuousSlider *pointSlider;

@end


@implementation InspectorTimelinePoint

- (void)willBeAdded {
    // The video duration is first loaded asynchronously, so we need to watch it for updates
    SKNode *videoNode = [self.selection.managedNodes objectAtIndex:0];
    [videoNode addObserver:self forKeyPath:@"resource.duration" options:NSKeyValueObservingOptionInitial context:InspectorTimelinePointContext];
    
    self.posterFrameTime = [[self propertyForSelection] doubleValue];
    // Handle the case where the duration hasn't been found yet
    // If we try to set the slider to a value outside the bounds (default max is 100) then it'll constrain it
    // We bump up the max value here to avoid that
    if (self.posterFrameTime > self.pointSlider.maxValue) {
        self.pointSlider.maxValue = self.posterFrameTime;
    }
    self.pointSlider.doubleValue = self.posterFrameTime;
    
    // Intentionaly not setting this on the node until the mouse is up
    // We don't need to live-update the poster frame while dragging
    __weak __typeof(self) weakSelf = self;
    self.pointSlider.mouseUpHandler = ^(NSEvent *event) {
        [weakSelf setPropertyForSelection:@(self.posterFrameTime)];
    };
    
}

- (void)willBeRemoved {
    SKNode *videoNode = [self.selection.managedNodes objectAtIndex:0];
    [videoNode removeObserver:self forKeyPath:@"resource.duration"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != InspectorTimelinePointContext) return;
    
    if ([keyPath isEqualToString:@"resource.duration"]) {
        NSTimeInterval duration = [[object valueForKeyPath:keyPath] doubleValue];
        self.pointSlider.maxValue = duration;
    }
}

// This will be called while the handle is being dragged
- (IBAction)updatePosterFrameTime:(NSSlider *)sender {
    self.posterFrameTime = sender.doubleValue;
}

#pragma mark Properties

- (void)setPosterFrameTime:(NSTimeInterval)posterFrameTime {
    if (_posterFrameTime == posterFrameTime) return;
    
    _posterFrameTime = posterFrameTime;
    
    self.timeField.stringValue = [self formattedTimeInterval:posterFrameTime];
}

#pragma mark Helpers

- (NSString *)formattedTimeInterval:(NSTimeInterval)timeInterval {
    NSUInteger h = (NSInteger)timeInterval / 3600;
    NSUInteger m = ((NSInteger)timeInterval / 60) % 60;
    NSUInteger s = timeInterval > 0 ? (NSInteger)timeInterval % 60 : 0;
    NSInteger integer = (NSInteger)timeInterval;
    NSUInteger ms = (timeInterval - (double)integer) * 1000;
    
    NSString *formattedTime = [NSString stringWithFormat:@"%lu:%02lu:%02lu.%003lu", (unsigned long)h, (unsigned long)m, (unsigned long)s, (unsigned long)ms];
    return formattedTime;
}

@end
