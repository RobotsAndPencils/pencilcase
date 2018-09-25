//
//  PCJSContext.h
//  
//
//  Created by Brandon Evans on 2014-12-17.
//
//

#import "RPJSContext.h"

extern NSString * const PCJSContextEventNotificationName;
extern NSString * const PCJSContextEventNotificationEventNameKey;
extern NSString * const PCJSContextEventNotificationArgumentsKey;

@interface PCJSContext : RPJSContext

#pragma mark - Events

/**
 *  Trigger a global event on the `Event` EventEmitter
 *
 *  @param name The name of the event to trigger
 */
- (void)triggerEventWithName:(NSString *)name;

/**
 *  Trigger a global event on the `Event` EventEmitter with an array of arguments
 *
 *  @param name      The name of the event to trigger
 *  @param arguments Array of argument values. The argument values will be converted to the appropriate JS values according to the JSValue documentation.
 */
- (void)triggerEventWithName:(NSString *)name arguments:(NSArray *)arguments;

/**
 *  Trigger a global event on the `Event` EventEmitter with an array of arguments logging the event name if enabled.
 *
 *  @param name      The name of the event to trigger
 *  @param arguments Array of argument values. The argument values will be converted to the appropriate JS values according to the JSValue documentation.
 *  @param loggingEnabled if enabled this method will PCLog the event name.
 */
- (void)triggerEventWithName:(NSString *)name arguments:(NSArray *)arguments loggingEnabled:(BOOL)loggingEnabled;

/**
 *  Trigger an event on a JS object. The Object prototype is extended with EventEmitter, so this should work on all native or bridged objects.
 *
 *  @param instanceName The instance name of the object
 *  @param eventName    The name of the event to trigger
 */
- (void)triggerEventOnJavaScriptRepresentation:(NSString *)javaScriptRepresentation eventName:(NSString *)eventName;

/**
 *  Trigger an event on a JS object with an array of arguments. The Object prototype is extended with EventEmitter, so this should work on all native or bridged objects.
 *
 *  @param instanceName The instance name of the object
 *  @param eventName    The name of the event to trigger
 *  @param arguments    Array of argument values. The argument values will be converted to the appropriate JS values according to the JSValue documentation.
 */
- (void)triggerEventOnJavaScriptRepresentation:(NSString *)javaScriptRepresentation eventName:(NSString *)eventName arguments:(NSArray *)arguments;

/**
 *  Trigger an event on a JS object with an array of arguments logging the event name if enabled. The Object prototype is extended with EventEmitter, so this should work on all native or bridged objects.
 *
 *  @param instanceName The instance name of the object
 *  @param eventName    The name of the event to trigger
 *  @param arguments    Array of argument values. The argument values will be converted to the appropriate JS values according to the JSValue documentation.
 *  @param loggingEnabled    if enabled this method will PCLog the event name.
 */
- (void)triggerEventOnJavaScriptRepresentation:(NSString *)javaScriptRepresentation eventName:(NSString *)eventName arguments:(NSArray *)arguments loggingEnabled:(BOOL)loggingEnabled;

/**
 @discussion Call before letting go to ensure context has a chance to clean up and prevent any never-ending event cycles.
 */
- (void)tearDown;

@end
