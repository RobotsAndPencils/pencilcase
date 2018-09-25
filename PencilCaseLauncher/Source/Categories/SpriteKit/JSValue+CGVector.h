//
//  JSValue+CGVector.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-09-03.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

@interface JSValue (CGVector)

/*!
 @method
 @abstract Create a JSValue from a CGVector.
 @result A newly allocated JavaScript object containing properties
 named <code>dx</code> and <code>dy</code>, with values from the CGPoint.
 */
+ (JSValue *)valueWithVector:(CGVector)vector inContext:(JSContext *)context;

/*!
 @method
 @abstract Convert a JSValue to a CGVector.
 @discussion Reads the properties named <code>dx</code> and <code>dy</code> from
 this JSValue, and converts the results to double.
 @result The new CGVector.
 */
- (CGVector)toVector;

@end
