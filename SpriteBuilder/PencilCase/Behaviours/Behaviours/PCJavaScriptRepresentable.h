//
//  PCJavaScriptRepresentable.h
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-12-11.
//
//

@protocol PCJavaScriptRepresentable <NSObject>

@required
/**
 *  Examples: Creation.getNodeWithUUID('x-x-x-x'), Event.on('name', function() { ... });
 *
 *  @return A string that properly represents the object when evaluated in the PC JS runtime
 */
- (NSString *)javaScriptRepresentation;

@optional
/**
 *  Only needs to be implemented if you need to pass other values in. Whens pass their then representations to their statement to insert in the when callback with this method.
 *
 *  @param values @{ template variable names : template variable value }
 *
 *  @return A string that properly represents the object when evaluated in the PC JS runtime
 */
- (NSString *)javaScriptRepresentationWithValues:(NSDictionary *)values;

@end
