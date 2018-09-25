//
//  PCSlideNode+JSExport.m
//  
//
//  Created by Stephen Gazzard on 2015-02-06.
//
//

#import "PCSlideNode+JSExport.h"

@implementation PCSlideNode (JSExport)

- (void)playTimelineWithName:(NSString *)timelineName jsCallback:(JSValue *)jsCallback {
    JSManagedValue *managedCallback;
    if (jsCallback) {
        managedCallback = [JSManagedValue managedValueWithValue:jsCallback andOwner:self];
    }

    [self playTimelineWithName:timelineName completion:^{
        if (managedCallback) [managedCallback.value callWithArguments:@[]];
    }];
}

@end
