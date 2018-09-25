//
//  PCControlSubclass.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-22.
//
//

#import "PCControl.h"

/// -----------------------------------------------------------------------
/// @name Methods Used by Sub-Classes
/// -----------------------------------------------------------------------

@interface PCControl (Subclass)

/**
 *  Used by sub-classes. This method is called to trigger an action callback. E.g. CCButton calls this method when the button is tapped.
 */
- (void)triggerAction;

/**
 *  Used by sub-classes. This method is called every time the control's state changes, it's default behavior is to call the needsLayout method.
 */
- (void)stateChanged;

/**
 *  Used by sub-classes. This method should be called whenever the control needs to update its layout. It will force a call to the layout method at the beginning of the next draw cycle.
 */
- (void)setNeedsLayout;

/**
 *  Used by sub classes. Override this method to do any layout needed by the component. This can include setting positions or sizes of child labels or sprites as well as the compontents contentSize.
 */
- (void)layout;

/**
 *  Used by sub-classes. Override this method if you are using custom properties and need to set them by name using the setValue:forKey method. This is needed for integration with editors such as SpriteBuilder. When overriding this method, make sure to call its super method if you cannot handle the key.
 *
 *  @param value The value to set.
 *  @param key   The key to set the value for.
 *  @param state The state to set the value for.
 */
- (void)setValue:(id)value forKey:(NSString *)key state:(PCControlState)state;

/**
 *  Used by sub-classes. Override this method to return values of custom properties that are set by state.
 *  @see setValue:forKey:state:
 *
 *  @param key   The key to retrieve the value for.
 *  @param state The state to retrieve the value for.
 *
 *  @return The value for the specified key and value or `NULL` if no such value exist.
 */
- (id)valueForKey:(NSString *)key state:(PCControlState)state;

/**
 *  Used by sub-classes. Called when a touch enters the component. By default this happes if the touch down is within the control, if the claimsUserEvents property is set to false this will also happen if the touch starts outside of the control.
 *
 *  @param touch Touch that entered the component.
 *  @param event Event associated with the touch.
 */
- (void) touchEntered:(UITouch*) touch withEvent:(UIEvent*)event;

/**
 *  Used by sub-classes. Called when a touch exits the component.
 *
 *  @param touch Touch that exited the component
 *  @param event Event associated with the touch.
 */
- (void) touchExited:(UITouch*) touch withEvent:(UIEvent*) event;

/**
 *  Used by sub-classes. Called when a touch that started inside the component is ended inside the component. E.g. for CCButton, this triggers the buttons callback action.
 *
 *  @param touch Touch that is released inside the component.
 *  @param event Event associated with the touch.
 */
- (void) touchUpInside:(UITouch*) touch withEvent:(UIEvent*) event;

/**
 *  Used by sub-classes. Called when a touch that started inside the component is ended outside the component. E.g. for CCButton, this doesn't trigger any callback action.
 *
 *  @param touch Touch that is release outside of the component.
 *  @param event Event associated with the touch.
 */
- (void) touchUpOutside:(UITouch*) touch withEvent:(UIEvent*) event;

@end