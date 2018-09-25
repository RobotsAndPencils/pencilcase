//
//  SMDoubleSliderCell.m
//
//SMDoubleSlider Copyright (c) 2003-2010, Snowmint Creative Solutions LLC http://www.snowmintcs.com/
//All rights reserved.
//
//Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//• Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//• Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//• Neither the name of Snowmint Creative Solutions LLC nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
//
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <AppKit/AppKit.h>

#import "SMDoubleSliderCell.h"
#import "SMDoubleSlider.h"

@interface SMDoubleSliderCell(_sm_Private)
	// A private method to calculate the rectangle of the low knob.
	- (NSRect)_sm_loKnobRect;
@end

@implementation SMDoubleSliderCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    BOOL	tempBool;

    self = [ super initWithCoder:aDecoder ];

    if ( nil != self )
    {
		if ( [ aDecoder allowsKeyedCoding ] )
		{
			_sm_loValue = [ aDecoder decodeDoubleForKey:@"loValue" ];
			tempBool = [ aDecoder decodeBoolForKey:@"lockedSliders" ];
		}
		else
		{
			[ aDecoder decodeValueOfObjCType:@encode(double) at:&_sm_loValue ];
			[ aDecoder decodeValueOfObjCType:@encode(BOOL) at:&tempBool ];
		}

		_sm_flags.lockedSliders = tempBool;

		// Make sure our value is between min and max.
		if ( [ self minValue ] > _sm_loValue )
			_sm_loValue = [ self minValue ];
		if ( [ self maxValue ] < _sm_loValue )
			_sm_loValue = [ self maxValue ];

		_sm_flags.isTrackingLoKnob = YES;
	}
	
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    BOOL	tempBool;

    [ super encodeWithCoder:aCoder ];

	tempBool = _sm_flags.lockedSliders;

	if ( [ aCoder allowsKeyedCoding ] )
	{
		[ aCoder encodeDouble:_sm_loValue forKey:@"loValue" ];
		[ aCoder encodeBool:tempBool forKey:@"lockedSliders" ];
	}
	else
	{
		[ aCoder encodeValueOfObjCType:@encode(double) at:&_sm_loValue ];
		[ aCoder encodeValueOfObjCType:@encode(BOOL) at:&tempBool ];
	}
}

- (id)copyWithZone:(NSZone *)zone
{
    SMDoubleSliderCell *copy;

    copy = [ super copyWithZone:zone ];

    [ copy setDoubleLoValue:[ self doubleLoValue ] ];
    [ copy setLockedSliders:[ self lockedSliders ] ];

    return copy;
}

- (void)setMinValue:(double)aDouble
{
    // Make sure we check both lo and hi values.
    if ( [ self doubleLoValue ] < aDouble )
        [ self setDoubleLoValue:aDouble ];
    if ( [ self doubleHiValue ] < aDouble )
        [ self setDoubleHiValue:aDouble ];

    [ super setMinValue:aDouble ];
}

- (void)setMaxValue:(double)aDouble
{
    // Make sure we check both lo and hi values.
    if ( [ self doubleLoValue ] > aDouble )
        [ self setDoubleLoValue:aDouble ];
    if ( [ self doubleHiValue ] > aDouble )
        [ self setDoubleHiValue:aDouble ];

    [ super setMaxValue:aDouble ];
}

/*- (void)setShowsFirstResponder:(BOOL)inValue
{
    NSLog( @"%x -setShowsFirstResponder:%d (was %d) dir=%d", self, inValue, _cFlags.showsFirstResponder,
                [ [ [ self controlView ] window ] keyViewSelectionDirection ] );
    if ( inValue && !_cFlags.showsFirstResponder &&
                [ [ [ self controlView ] window ] keyViewSelectionDirection ] != NSDirectSelection )
    {
        [ self setTrackingLoKnob:( [ [ [ self controlView ] window ] keyViewSelectionDirection ] ==
                    NSSelectingNext ) ];
    }

    [ super setShowsFirstResponder:inValue ];
}*/

/*- (BOOL)acceptsFirstResponder
{
    BOOL		result;

    NSLog( @"%x -acceptsFirstResponder called", self );
    result = [ super acceptsFirstResponder ];
    if ( result && [ [ [ self controlView ] window ] keyViewSelectionDirection ] != NSDirectSelection )
        [ self setTrackingLoKnob:( [ [ [ self controlView ] window ] keyViewSelectionDirection ] == NSSelectingNext ) ];

    return result;
}*/

- (void)drawKnob
{
    NSRect	loKnobRect;
    double	saveValue = _value;
    BOOL	savePressed = _scFlags.isPressed;

    // Draw the lower knob first.
    if ( !_sm_flags.mouseTrackingSwapped )
        // If we're tracking the lo knob with the mouse, _value already has the lo knob value.
        // Otherwise, we need to stuff the lo value into _value to calculate correctly.
        _value = _sm_loValue;

    // Figure out the focus ring style and pressed state of the low knob.
    _sm_flags.removeFocusRingStyle = ( _cFlags.showsFirstResponder && ![ self trackingLoKnob ] );
    _scFlags.isPressed = ( savePressed && [ self trackingLoKnob ] );

    loKnobRect = [ self knobRectFlipped:[ [ self controlView ] isFlipped ] ];
    [ self drawKnob:loKnobRect ];

    // Now, draw the upper knob in the correct state.
    if ( _sm_flags.mouseTrackingSwapped )
        // If we're tracking the lo knob, the hi knob value is saved in _sm_saveValue.
        _value = _sm_saveValue;
    else
        // Restore to proper position of hi knob.
        _value = saveValue;

    // Figure out the focus ring style and pressed state of the high knob.
    _sm_flags.removeFocusRingStyle = ( _cFlags.showsFirstResponder && [ self trackingLoKnob ] );
    _scFlags.isPressed = ( savePressed && ![ self trackingLoKnob ] );

    [ super drawKnob ];

    // Reset to whatever values we had at the beginning of this method.
    _value = saveValue;
    _scFlags.isPressed = savePressed;
    _sm_flags.removeFocusRingStyle = NO;
}

- (void)drawKnob:(NSRect)inRect
{
	unsigned int	t_focus_ring_type;

    if ( _sm_flags.removeFocusRingStyle )
	{
		if ( [ self respondsToSelector:@selector(focusRingType) ] )
		{
			t_focus_ring_type = [ self focusRingType ];
			[ self setFocusRingType:NSFocusRingTypeNone ];
		}

		// This seems backwards, but the problem is that NSSliderCell has set the focus ring style,
		// and we want to remove that style.  So, we pop the graphics state off the stack.
        [ [ NSGraphicsContext currentContext ] restoreGraphicsState ];
	}

    [ super drawKnob:inRect ];

    if ( _sm_flags.removeFocusRingStyle )
    {
		if ( [ self respondsToSelector:@selector(focusRingType) ] )
		{
			[ self setFocusRingType:t_focus_ring_type ];
		}

		// Reset the graphics context stack and add the correct focus ring style back in.
		[ [ NSGraphicsContext currentContext ] saveGraphicsState ];
		NSSetFocusRingStyle( NSFocusRingAbove );
    }
}

// Mouse tracking doesn't use the accessor methods for the value.
// That means, we need to do some hocus pocus here to make it work right.
- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView
{
    NSRect		loKnobRect;

    // Determine if we're tracking the low knob or not.
    loKnobRect = [ self _sm_loKnobRect ];
    if ( [ self isVertical ] )
    {
        if ( [ controlView isFlipped ] )
            [ self setTrackingLoKnob:( startPoint.y > loKnobRect.origin.y ) ];
        else
            [ self setTrackingLoKnob:( startPoint.y < loKnobRect.origin.y +
                        loKnobRect.size.height ) ];
    }
    else
        [ self setTrackingLoKnob:( startPoint.x < loKnobRect.origin.x + loKnobRect.size.width ) ];

    // Make sure that the user hasn't jammed both knobs up against the minimum value.
    if ( [ self trackingLoKnob ] && NSEqualRects( loKnobRect,
                [ self knobRectFlipped:[ controlView isFlipped ] ] ) )
        [ self setTrackingLoKnob:( _sm_loValue > [ self minValue ] ) ];

    // Make sure that the entire lo knob gets erased if it's moved the first time.
    if ( [ self trackingLoKnob ] )
        [ controlView setNeedsDisplayInRect:loKnobRect ];

    // Save the value of the hi knob.
    _sm_saveValue = _value;

    // The _value variable (NSSliderCell implementation without accessor method calls) is used to track
    // any knob with the mouse.
    // However, if the user is tracking the lo knob, we need to switch in our lo value for the knob.
    _sm_flags.mouseTrackingSwapped = [ self trackingLoKnob ];
    if ( _sm_flags.mouseTrackingSwapped )
        _value = _sm_loValue;

    return [ super startTrackingAt:startPoint inView:controlView ];
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView *)controlView
{
    BOOL	result;

    result = [ super continueTracking:lastPoint at:currentPoint inView:controlView ];

    // NOTE: This doesn't seem to be a problem for continuous sliders, although I did think about that.
    // If the super implementation of this method sent the action method, we'd be hosed because we're possibly
    // changing the values below here.  However, Cocoa seems to send the action after this method is complete.
    // That's exactly what we want. :)
    if ( _sm_flags.mouseTrackingSwapped )
    {
        // Limit to maximum of hi knob value (saved in _sm_saveValue).
        if ( _value > _sm_saveValue )
            _value = _sm_saveValue;

		// Only update the bound controller if this slider is continuous
		if ([self isContinuous])
		{
			[(SMDoubleSlider*)controlView updateBoundControllerLoValue:_value];
		}
    }
    else
    {
        // Limit to minimum of lo knob value.
        if ( _value < _sm_loValue )
            _value = _sm_loValue;
		
		// Only update the bound controller if this slider is continuous
		if ([self isContinuous])
		{
			[(SMDoubleSlider*)controlView updateBoundControllerHiValue:_value];
		}
    }

    return result;
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag
{
    if ( _sm_flags.mouseTrackingSwapped )
    {
        // If we were tracking the lo knob, stick the correct values into the correct places.
        _sm_loValue = _value;
        _value = _sm_saveValue;
        _sm_flags.mouseTrackingSwapped = NO;
        [ controlView setNeedsDisplayInRect:[ self _sm_loKnobRect ] ];
		
		// Update the bound controller whether the slider is continuous or not
		[(SMDoubleSlider*)controlView updateBoundControllerLoValue:_sm_loValue];
    }
    else
    {
		// Update the bound controller whether the slider is continuous or not
		[(SMDoubleSlider*)controlView updateBoundControllerHiValue:_value];
    }

    [ super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag ];
}

#pragma mark -

- (BOOL)trackingLoKnob
{
    return _sm_flags.isTrackingLoKnob;
}

- (void)setTrackingLoKnob:(BOOL)inValue
{
    if ( _sm_flags.isTrackingLoKnob != inValue )
    {
        _sm_flags.isTrackingLoKnob = inValue;
        [ (NSControl *)[ self controlView ] updateCell:self ];
    }
}

- (BOOL)lockedSliders
{
    return _sm_flags.lockedSliders;
}

- (void)setLockedSliders:(BOOL)inLocked
{
    if ( _sm_flags.lockedSliders != inLocked )
    {
        _sm_flags.lockedSliders = inLocked;

        if ( inLocked )
            [ self setDoubleLoValue:[ self doubleHiValue ] ];

        [ (NSControl *)[ self controlView ] updateCell:self ];
    }
}

#pragma mark -

- (NSString *)stringValue
{
    if ( [ self trackingLoKnob ] )
        return [ self stringLoValue ];
    else
        return [ self stringHiValue ];
}

- (id)objectValue
{
    if ( [ self trackingLoKnob ] )
        return [ self objectLoValue ];
    else
        return [ self objectHiValue ];
}

- (int)intValue
{
    if ( [ self trackingLoKnob ] )
        return [ self intLoValue ];
    else
        return [ self intHiValue ];
}

- (float)floatValue
{
    if ( [ self trackingLoKnob ] )
        return [ self floatLoValue ];
    else
        return [ self floatHiValue ];
}

- (double)doubleValue
{
    if ( [ self trackingLoKnob ] )
        return [ self doubleLoValue ];
    else
        return [ self doubleHiValue ];
}

- (void)setStringValue:(NSString *)aString
{
    if ( [ self trackingLoKnob ] )
        [ self setStringLoValue:aString ];
    else
        [ self setStringHiValue:aString ];
}

- (void)setObjectValue:(id)obj
{
    if ( [ self trackingLoKnob ] )
        [ self setObjectLoValue:obj ];
    else
        [ self setObjectHiValue:obj ];
}

- (void)setIntValue:(int)anInt
{
    if ( [ self trackingLoKnob ] )
        [ self setIntLoValue:anInt ];
    else
        [ self setIntHiValue:anInt ];
}

- (void)setFloatValue:(float)aFloat
{
    if ( [ self trackingLoKnob ] )
        [ self setFloatLoValue:aFloat ];
    else
        [ self setFloatHiValue:aFloat ];
}

- (void)setDoubleValue:(double)aDouble
{
    if ( [ self trackingLoKnob ] )
        [ self setDoubleLoValue:aDouble ];
    else
        [ self setDoubleHiValue:aDouble ];
}

#pragma mark -

- (double)doubleHiValue
{
//    NSLog( @"SMDSCell -doubleHiValue called %g (%d)", [ super doubleValue ],
//                _sm_flags.mouseTrackingSwapped );
    if ( _sm_flags.mouseTrackingSwapped )
        return _sm_saveValue;
    else
        return [ super doubleValue ];
}

- (void)setDoubleHiValue:(double)aDouble
{
//    NSLog( @"SMDSCell -setDoubleHiValue:%g called (%d)", aDouble,
//                _sm_flags.mouseTrackingSwapped );

    // Limit to minimum of lo knob value.
    if ( aDouble < [ self doubleLoValue ] )
        aDouble = [ self doubleLoValue ];
    if ( aDouble > [ self maxValue ] )
        aDouble = [ self maxValue ];

    if ( _sm_flags.mouseTrackingSwapped )
    {
        _sm_saveValue = aDouble;
        [ (NSControl *)[ self controlView ] updateCell:self ];
    }
    else
        [ super setDoubleValue:aDouble ];
}

- (id)objectHiValue
{
    return [ NSNumber numberWithDouble:[ self doubleHiValue ] ];
}

- (void)setObjectHiValue:(id)obj
{
    if ( [ obj respondsToSelector:@selector(doubleHiValue) ] )
        [ self setDoubleHiValue:[ obj doubleHiValue ] ];
    else if ( [ obj respondsToSelector:@selector(doubleValue) ] )
        [ self setDoubleHiValue:[ obj doubleValue ] ];
    else if ( [ obj respondsToSelector:@selector(floatValue) ] )
        [ self setDoubleHiValue:[ obj floatValue ] ];
    else if ( [ obj respondsToSelector:@selector(intValue) ] )
        [ self setDoubleHiValue:[ obj intValue ] ];
    else if ( [ obj respondsToSelector:@selector(stringValue) ] )
        [ self setStringHiValue:[ obj stringValue ] ];
	else
		[ self setDoubleHiValue:0.0 ];
}

- (NSString *)stringHiValue
{
    return [ NSString stringWithFormat:@"%g", [ self doubleHiValue ] ];
}

- (void)setStringHiValue:(NSString *)aString
{
    NSParameterAssert( nil != aString );

    [ self setDoubleHiValue:[ aString doubleValue ] ];
}

- (int)intHiValue
{
    return (int)[ self doubleHiValue ];
}

- (void)setIntHiValue:(int)anInt
{
    [ self setDoubleHiValue:anInt ];
}

- (float)floatHiValue
{
    return (float)[ self doubleHiValue ];
}

- (void)setFloatHiValue:(float)aFloat
{
    [ self setDoubleHiValue:aFloat ];
}

/*- (void)takeIntHiValueFrom:(id)sender
{
    [ super takeIntValueFrom:sender ];
}

- (void)takeFloatHiValueFrom:(id)sender
{
    [ super takeFloatValueFrom:sender ];
}

- (void)takeDoubleHiValueFrom:(id)sender
{
    [ super takeDoubleValueFrom:sender ];
}

- (void)takeStringHiValueFrom:(id)sender
{
    [ super takeStringValueFrom:sender ];
}

- (void)takeObjectHiValueFrom:(id)sender
{
    [ super takeObjectValueFrom:sender ];
}*/

#pragma mark -

#if MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5
	- (void)setIntegerHiValue:(NSInteger)anInt;
	{
		[ self setDoubleHiValue:anInt ];
	}
	- (NSInteger)integerHiValue;
	{
		return (NSInteger)[ self doubleHiValue ];
	}
	- (void)setIntegerLoValue:(NSInteger)anInt;
	{
		[ self setDoubleLoValue:anInt ];
	}
	- (NSInteger)integerLoValue;
	{
		return (NSInteger)[ self doubleLoValue ];
	}
#endif

#pragma mark -

- (double)doubleLoValue
{
//    NSLog( @"SMDSCell -doubleLoValue called %g (%d)", _sm_loValue, _sm_flags.mouseTrackingSwapped );
    if ( _sm_flags.mouseTrackingSwapped )
        return _value;
    else
        return _sm_loValue;
}

- (void)setDoubleLoValue:(double)aDouble
{
//    NSLog( @"SMDSCell -setDoubleLoValue:%g called (%d)", aDouble,
//                _sm_flags.mouseTrackingSwapped );
    if ( aDouble > [ self doubleHiValue ] )
        aDouble = [ self doubleHiValue ];
    if ( aDouble < [ self minValue ] )
        aDouble = [ self minValue ];

    if ( _sm_flags.mouseTrackingSwapped )
        [ super setDoubleValue:aDouble ];
    else
    {
        _sm_loValue = aDouble;
        [ (NSControl *)[ self controlView ] updateCell:self ];
    }
}

- (id)objectLoValue
{
    return [ NSNumber numberWithDouble:[ self doubleLoValue ] ];
}

- (void)setObjectLoValue:(id)obj
{
    if ( [ obj respondsToSelector:@selector(doubleLoValue) ] )
        [ self setDoubleLoValue:[ obj doubleLoValue ] ];
    else if ( [ obj respondsToSelector:@selector(doubleValue) ] )
        [ self setDoubleLoValue:[ obj doubleValue ] ];
    else if ( [ obj respondsToSelector:@selector(floatValue) ] )
        [ self setDoubleLoValue:[ obj floatValue ] ];
    else if ( [ obj respondsToSelector:@selector(intValue) ] )
        [ self setDoubleLoValue:[ obj intValue ] ];
    else if ( [ obj respondsToSelector:@selector(stringValue) ] )
        [ self setStringLoValue:[ obj stringValue ] ];
	else
        [ self setDoubleLoValue:0.0 ];
}

- (NSString *)stringLoValue
{
    return [ NSString stringWithFormat:@"%g", [ self doubleLoValue ] ];
}

- (void)setStringLoValue:(NSString *)aString
{
    NSParameterAssert( nil != aString );

    [ self setDoubleLoValue:[ aString doubleValue ] ];
}

- (int)intLoValue
{
    return (int)[ self doubleLoValue ];
}

- (void)setIntLoValue:(int)anInt
{
    [ self setDoubleLoValue:anInt ];
}

- (float)floatLoValue
{
    return (float)[ self doubleLoValue ];
}

- (void)setFloatLoValue:(float)aFloat
{
    [ self setDoubleLoValue:aFloat ];
}

/*- (void)takeIntLoValueFrom:(id)sender
{
    _sm_loValue = [ sender intValue ];
    [ (NSControl *)[ self controlView ] updateCell:self ];
}

- (void)takeFloatLoValueFrom:(id)sender
{
    _sm_loValue = [ sender floatValue ];
    [ (NSControl *)[ self controlView ] updateCell:self ];
}

- (void)takeDoubleLoValueFrom:(id)sender
{
    _sm_loValue = [ sender doubleValue ];
    [ (NSControl *)[ self controlView ] updateCell:self ];
}

- (void)takeStringLoValueFrom:(id)sender
{
    _sm_loValue = [ [ sender stringValue ] doubleValue ];
    [ (NSControl *)[ self controlView ] updateCell:self ];
}

- (void)takeObjectLoValueFrom:(id)sender
{
    [ self setObjectLoValue:[ sender objectValue ] ];
}*/

#pragma mark -

- (NSRect)_sm_loKnobRect
{
    NSRect	loKnobRect;
    double	saveValue;

    // Adjust the current value of the slider, get the rectangle, then reset the current value.
    saveValue = _value;
    _value = _sm_loValue;
    loKnobRect = [ self knobRectFlipped:[ [ self controlView ] isFlipped ] ];
    _value = saveValue;

    return loKnobRect;
}

@end
