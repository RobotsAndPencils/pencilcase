//
//  SKNode+Animation.h
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 15-02-03.
//
//

@import SpriteKit;
@import JavaScriptCore;

@protocol SKNodeAnimationExport <JSExport>

JSExportAs(animateProperty,
- (void)pc_animateProperty:(NSString *)propertyName value:(id)value duration:(CGFloat)duration completion:(JSValue *)completion
);

@end

@interface SKNode (Animation) <SKNodeAnimationExport>

/**
 *  Animates a set of valid property names to a value over a duration. The PencilCase UI only exposes the valid set of properties to the user.
 *
 *  @param propertyName The name of the property to animate. Invalid names will make no changes to properties.
 *  @param value        The value to change the property to. See the implementation for valid types.
 *  @param duration     The duration of the action.
 *  @param completion   A javascript callback that will be called with no arguments after the full duration, even for invalid properties that make no changes.
 */
- (void)pc_animateProperty:(NSString *)propertyName value:(id)value duration:(CGFloat)duration completion:(JSValue *)completion;

/**
*  Creates an action that changes a node's property from it's current value to a given value over a given duration
*
*  @param key       The property key to animate
*  @param toValue   The desired final value of the property
*  @param duration  The duration of the animation action
*
*  @return An action that changes the rotation of the node
*/
- (SKAction *)pc_animateKey:(NSString *)key toFloat:(CGFloat)toValue duration:(CGFloat)duration;

// Used to keep track of how many position actions are currently being run on a node.
// This is used to determine when a node that was dynamic should be changed back to that state after the actions complete
@property (nonatomic, assign) NSInteger positionActionCount;
@property (nonatomic, assign) BOOL originalDynamicism;

/**
 Informs the node that something that was controlling its position - an action, timeline animation, etc., has ended. If nothing is controlling its position,
 the node reverts to its original dynamic state.
 */
- (void)positionAnimationEnded;

/**
 Informs the node that something has started controlling its position, and it should stop participating as a dynamic physics object, if it has been doing such.
 */
- (void)positionActionStarted;

@end
