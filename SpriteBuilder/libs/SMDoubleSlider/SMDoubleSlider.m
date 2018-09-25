//
//  SMDoubleSlider.m
//
//SMDoubleSlider Copyright (c) 2003-2010, Snowmint Creative Solutions LLC http://www.snowmintcs.com/
//All rights reserved.
//
//Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//¥ Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//¥ Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//¥ Neither the name of Snowmint Creative Solutions LLC nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <AppKit/AppKit.h>

#import "SMDoubleSlider.h"
#import "SMDoubleSliderCell.h"

enum {
	kBindIdx_invalid = -1,
	kBindIdx_loValue = 0,
	kBindIdx_hiValue = 1
};
typedef			intptr_t		BindingIndex;

@implementation SMDoubleSlider

#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_3

+ (void)exposeBindings
{
	[self exposeBinding:@"objectLoValue"];
	[self exposeBinding:@"objectHiValue"];
}

- (void)unbindAll
{
	[self unbind:@"objectLoValue"];
	[self unbind:@"objectHiValue"];
}

+ (void)initialize
{
	if (self == [SMDoubleSlider class])
	{
		// Expose all bindings so that the IB Plugin can make them available in IB
		[self exposeBindings];
	}
}

// for IBPalette
- (Class)valueClassForBinding:(NSString *)bindingName
{
//	NSLog (@"valueClassForBinding %@", bindingName);

    if ([bindingName isEqualToString:@"objectLoValue"])
	{
		return [NSNumber class];
    }
	else if ([bindingName isEqualToString:@"objectHiValue"])
	{
		return [NSNumber class];
	}
	else
	{
		return [super valueClassForBinding:bindingName];
	}
}

- (BindingIndex)bindingNameToIndex:(NSString *)bindingName
{
    BindingIndex		idx = kBindIdx_invalid;
    if ([bindingName isEqualToString:@"objectLoValue"])
	{
		idx = kBindIdx_loValue;
	}
    else if ([bindingName isEqualToString:@"objectHiValue"])
	{
		idx = kBindIdx_hiValue;
	}
	return idx;
}

- (NSString *)bindingIndexToName:(BindingIndex)bindingIndex
{
	NSString *		bindingName;
	switch (bindingIndex)
	{
		case kBindIdx_loValue:
			bindingName = @"objectLoValue";
			break;
		case kBindIdx_hiValue:
			bindingName = @"objectHiValue";
			break;
		default:
			bindingName = nil;
			break;
	}
	return bindingName;
}

- (void)bind:(NSString *)bindingName
    toObject:(id)observableObject
 withKeyPath:(NSString *)observableKeyPath
     options:(NSDictionary *)options
{
//	NSLog (@"bind %@", bindingName);

	BindingIndex	idx = [self bindingNameToIndex:bindingName];
	
	switch (idx)
	{
		case kBindIdx_loValue:
		case kBindIdx_hiValue:
		{
			// register to receive notifications of changes
			[observableObject addObserver:self
				forKeyPath:observableKeyPath 
				options:0
				context:(void*)idx];
		}
		break;
	}
	
	[self setNeedsDisplay:YES];

	// must call super for the IBPalette to be enabled in IB
	[super bind:bindingName toObject:observableObject withKeyPath:observableKeyPath options:options];
}

- (void)unbind:(NSString*)bindingName
{
//	NSLog (@"unbind %@", bindingName);
	
	BindingIndex	idx = [self bindingNameToIndex:bindingName];
	
	switch (idx)
	{
		case kBindIdx_loValue:
		{
			NSDictionary *bindingInfo = [self infoForBinding:@"objectLoValue"];
			id observedObject = [bindingInfo objectForKey:NSObservedObjectKey];
			NSString *observedKeyPath = [bindingInfo objectForKey:NSObservedKeyPathKey];

			[observedObject removeObserver:self forKeyPath:observedKeyPath];
		}
		break;

		case kBindIdx_hiValue:
		{
			NSDictionary *bindingInfo = [self infoForBinding:@"objectHiValue"];
			id observedObject = [bindingInfo objectForKey:NSObservedObjectKey];
			NSString *observedKeyPath = [bindingInfo objectForKey:NSObservedKeyPathKey];

			[observedObject removeObserver:self forKeyPath:observedKeyPath];
		}
		break;
	}
	
    [self setNeedsDisplay:YES];

	[super unbind:bindingName];
}

// This is called when the NSController wants to change values
- (void)observeValueForKeyPath:(NSString *)keyPath
	ofObject:(id)object
	change:(NSDictionary*)change
	context:(void*)context
{
//	NSLog (@"observeValueForKeyPath %@", keyPath);

	(void)change;

	BindingIndex	idx = (BindingIndex)context;

	if (idx == kBindIdx_loValue)
	{
		NSDictionary *bindingInfo = [self infoForBinding:@"objectLoValue"];
		id observedObject = [bindingInfo objectForKey:NSObservedObjectKey];
		NSString *observedKeyPath = [bindingInfo objectForKey:NSObservedKeyPathKey];
//		NSDictionary *options = [bindingInfo objectForKey:NSOptionsKey];

		id	newLoValue = [observedObject valueForKeyPath:observedKeyPath];
//		NSLog (@"observeValueForKeyPath: newLoValue %@", newLoValue);
		[self setObjectLoValue:newLoValue];
	}
	else if (idx == kBindIdx_hiValue)
	{
		NSDictionary *bindingInfo = [self infoForBinding:@"objectHiValue"];
		id observedObject = [bindingInfo objectForKey:NSObservedObjectKey];
		NSString *observedKeyPath = [bindingInfo objectForKey:NSObservedKeyPathKey];
//		NSDictionary *options = [bindingInfo objectForKey:NSOptionsKey];

		id	newHiValue = [observedObject valueForKeyPath:observedKeyPath];
//		NSLog (@"observeValueForKeyPath: newHiValue %@", newHiValue);
		[self setObjectHiValue:newHiValue];
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
	
    [self setNeedsDisplay:YES];
}

- (void)setNilValueForKey:(NSString *)key
{
	BindingIndex	idx = [self bindingNameToIndex:key];
	if (idx == kBindIdx_loValue)
	{
		[self setDoubleLoValue:0.0];
	}
	else if (idx == kBindIdx_hiValue)
	{
		[self setDoubleHiValue:0.0];
	}
}

- (void)updateBoundControllerHiValue:(double)val
{
	NSDictionary *bindingInfo = [self infoForBinding:@"objectHiValue"];
	id observedObject = [bindingInfo objectForKey:NSObservedObjectKey];
	NSString *observedKeyPath = [bindingInfo objectForKey:NSObservedKeyPathKey];
//	NSDictionary *options = [bindingInfo objectForKey:NSOptionsKey];

	[observedObject setValue:[NSNumber numberWithDouble:val] forKeyPath:observedKeyPath];
}

- (void)updateBoundControllerLoValue:(double)val
{
	NSDictionary *bindingInfo = [self infoForBinding:@"objectLoValue"];
	id observedObject = [bindingInfo objectForKey:NSObservedObjectKey];
	NSString *observedKeyPath = [bindingInfo objectForKey:NSObservedKeyPathKey];
//	NSDictionary *options = [bindingInfo objectForKey:NSOptionsKey];

	[observedObject setValue:[NSNumber numberWithDouble:val] forKeyPath:observedKeyPath];
}

- (void)viewWillMoveToSuperview:(NSView*)newSuperview
{
	[super viewWillMoveToSuperview:newSuperview];

	// Disconnect all bindings when the view is disconnected from the view hierarchy
	if (newSuperview == nil) {
		[self unbindAll];
	}	
}

#endif

#pragma mark -

// ---------------------------------------------------------------------------------------------------------------
// A view must know how to archive and unarchive itself in order to be placed in a custom
// Interface Builder palette.
- (void)encodeWithCoder:(NSCoder*)coder
{
    [super encodeWithCoder:coder];
//		NSLog (@"coder %@", coder);
	
//	assert ([coder allowsKeyedCoding]);

	// Write attributes, none currently
}

// ---------------------------------------------------------------------------------------------------------------
- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super initWithCoder:decoder];
    if (self)
    {
//		assert ([decoder allowsKeyedCoding]);
//		NSLog (@"decoder %@", decoder);

		// Read archived attributes, none currently
    }
    return self;
}

#pragma mark -

+ (Class)cellClass
{
    return [ SMDoubleSliderCell class ];
}

- (void)keyDown:(NSEvent*)theEvent
{
	[self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
}

- (void)insertTab:(id)sender
{
	(void)sender;

	// Tab forwards...Switch from low to high knob tracking, or switch to the next control.
	if ( [ [self cell] trackingLoKnob ] )
		[ [self cell] setTrackingLoKnob:NO ];
	else
	{
		[ [self cell] setTrackingLoKnob:YES ];
		[[self window] selectNextKeyView:self];
	}

	[self setNeedsDisplay:YES];
}

- (void)insertBacktab:(id)sender
{
	(void)sender;

	// Tab backwards...Switch from high knob to low knob tracking, or switch to the next control.
	if ( ![ [self cell] trackingLoKnob ] )
		[ [self cell] setTrackingLoKnob:YES ];
	else
		[[self window] selectPreviousKeyView:self];
	
	[self setNeedsDisplay:YES];
}

- (BOOL)becomeFirstResponder
{
    BOOL	result = [ super becomeFirstResponder ];

    // Depending on which way we're going through the key loop, select either the hi knob or the lo knob.
    if ( result && [ [ self window ] keyViewSelectionDirection ] != NSDirectSelection )
        [ self setTrackingLoKnob:( [ [ self window ] keyViewSelectionDirection ] == NSSelectingNext ) ];

    return result;
}

#pragma mark -

- (BOOL)trackingLoKnob
{
    return [ [self cell] trackingLoKnob ];
}

- (void)setTrackingLoKnob:(BOOL)inValue
{
    [ [self cell] setTrackingLoKnob:inValue ];
}

- (BOOL)lockedSliders
{
    return [ [self cell] lockedSliders ];
}

- (void)setLockedSliders:(BOOL)inLocked
{
    [ [self cell] setLockedSliders:inLocked ];
}

#pragma mark -

- (void)setObjectHiValue:(id)obj
{
	if (obj && !NSIsControllerMarker(obj))
	{
		[self setEnabled:YES];
		[ [self cell] setObjectHiValue:obj ];
	}
	else
	{
		[self setEnabled:NO];
		[ [self cell] setObjectHiValue:nil ];
	}
}

- (void)setStringHiValue:(NSString *)aString
{
    [ [self cell] setStringHiValue:aString ];
}

- (void)setIntHiValue:(int)anInt
{
    [ [self cell] setIntHiValue:anInt ];
}

- (void)setFloatHiValue:(float)aFloat
{
    [ [self cell] setFloatHiValue:aFloat ];
}

- (void)setDoubleHiValue:(double)aDouble
{
    [ [self cell] setDoubleHiValue:aDouble ];
}

- (id)objectHiValue
{
    return [ [self cell] objectHiValue ];
}

- (NSString *)stringHiValue
{
    return [ [self cell] stringHiValue ];
}

- (int)intHiValue
{
    return [ [self cell] intHiValue ];
}

- (float)floatHiValue
{
    return [ [self cell] floatHiValue ];
}

- (double)doubleHiValue
{
    return [ [self cell] doubleHiValue ];
}

#pragma mark -

#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
	- (void)setIntegerHiValue:(NSInteger)anInt;
	{
		[ [ self cell ] setIntegerHiValue:anInt ];
	}
	- (NSInteger)integerHiValue;
	{
		return [ [ self cell ] integerHiValue ];
	}
	- (void)setIntegerLoValue:(NSInteger)anInt;
	{
		[ [ self cell ] setIntegerLoValue:anInt ];
	}
	- (NSInteger)integerLoValue;
	{
		return [ [ self cell ] integerLoValue ];
	}
#endif

#pragma mark -

- (void)setObjectLoValue:(id)obj
{
	if (obj && !NSIsControllerMarker(obj))
	{
		[self setEnabled:YES];
		[ [self cell] setObjectLoValue:obj ];
	}
	else
	{
		[self setEnabled:NO];
		[ [self cell] setObjectLoValue:nil ];
	}
}

- (void)setStringLoValue:(NSString *)aString
{
    [ [self cell] setStringLoValue:aString ];
}

- (void)setIntLoValue:(int)anInt
{
    [ [self cell] setIntLoValue:anInt ];
}

- (void)setFloatLoValue:(float)aFloat
{
    [ [self cell] setFloatLoValue:aFloat ];
}

- (void)setDoubleLoValue:(double)aDouble
{
    [ [self cell] setDoubleLoValue:aDouble ];
}

- (id)objectLoValue
{
    return [ [self cell] objectLoValue ];
}

- (NSString *)stringLoValue
{
    return [ [self cell] stringLoValue ];
}

- (int)intLoValue
{
    return [ [self cell] intLoValue ];
}

- (float)floatLoValue
{
    return [ [self cell] floatLoValue ];
}

- (double)doubleLoValue
{
    return [ [self cell] doubleLoValue ];
}

@end
