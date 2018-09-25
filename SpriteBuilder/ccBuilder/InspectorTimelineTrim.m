//
//  InspectorTimelineTrim.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-05-29.
//
//

#import "InspectorTimelineTrim.h"

#import "SMDoubleSlider.h"

const NSTimeInterval TimelineTrimMinimumDuration = 1.0;
const CGFloat TimelineTrimInitialEndpoint = -1;
static void *InspectorTimelineTrimContext = &InspectorTimelineTrimContext;


@interface InspectorTimelineTrim ()

@property (nonatomic, weak) IBOutlet SMDoubleSlider *slider;
@property (nonatomic, weak) IBOutlet NSTextField *lowValueField;
@property (nonatomic, weak) IBOutlet NSTextField *highValueField;

@property (nonatomic, assign) NSTimeInterval startPoint;
@property (nonatomic, assign) NSTimeInterval endPoint;

@end


@implementation InspectorTimelineTrim

- (void)willBeAdded {
    [self.slider bind:@"objectLoValue" toObject:self withKeyPath:@"startPoint" options:nil];
    [self.slider bind:@"objectHiValue" toObject:self withKeyPath:@"endPoint" options:nil];
    
    // Specifically in this order with endPoint first
    // If we set startPoint first, the constrain code will set it to 0 while endPoint is at 0
    // Need to grab it from the array first though otherwise setting endPoint will override it
    NSTimeInterval startPoint = [[[self propertyForSelection] firstObject] doubleValue];
    self.endPoint = [[[self propertyForSelection] lastObject] doubleValue];
    self.startPoint = startPoint;
    
    // The video duration is first loaded asynchronously, so we need to watch it for updates
    SKNode *videoNode = [self.selection.managedNodes firstObject];
    [videoNode addObserver:self forKeyPath:@"resource.duration" options:NSKeyValueObservingOptionInitial context:InspectorTimelineTrimContext];
}

- (void)willBeRemoved {
    SKNode *videoNode = [self.selection.managedNodes firstObject];
    [videoNode removeObserver:self forKeyPath:@"resource.duration" context:InspectorTimelineTrimContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != InspectorTimelineTrimContext) return;

    if ([keyPath isEqualToString:@"resource.duration"]) {
        NSTimeInterval duration = [[object valueForKeyPath:keyPath] doubleValue];
        self.slider.minValue = 0.0;
        self.slider.maxValue = duration;
        // The default maxValue for NSSliders is 100
        // If the endPoint is set while the maxValue is that default value, the slider knob will be constrained to 100
        // If the duration gets updated to the proper value (likely > 100s) the slider knob will still be constrained
        // Resetting it here fixes this
        self.slider.objectHiValue = @(self.endPoint);
    }
}

- (void)refresh {
    NSArray *trimTimes = [self.selection valueForKey:self.propertyName];
    self.startPoint = [trimTimes[0] floatValue];
    self.endPoint = [trimTimes[1] floatValue];
}

#pragma mark Properties

- (void)setStartPoint:(NSTimeInterval)startPoint {
    if (self.endPoint - startPoint < TimelineTrimMinimumDuration) {
        startPoint = fmax(self.endPoint - TimelineTrimMinimumDuration, 0.0);
    }
    
    _startPoint = startPoint;
    [self setPropertyForSelection:@[ @(startPoint), @(self.endPoint) ]];
    self.lowValueField.stringValue = [self formattedTimeInterval:startPoint];
}

- (void)setEndPoint:(NSTimeInterval)endPoint {
    // Don't constrain if the new value is equal to the initial placeholder value (set in CCBProperties.plist, defined as a constant at the top of this file)
    if (endPoint - self.startPoint < TimelineTrimMinimumDuration && endPoint != TimelineTrimInitialEndpoint) {
        endPoint = self.startPoint + TimelineTrimMinimumDuration;
    }
    
    _endPoint = endPoint;
    [self setPropertyForSelection:@[ @(self.startPoint), @(endPoint) ]];
    self.highValueField.stringValue = [self formattedTimeInterval:endPoint];
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
