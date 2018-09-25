//
// Created by Brandon Evans on 15-03-20.
//

// Simple wrapper around JSHint
@interface PCBehaviourJavaScriptValidator : NSObject

// Returns an array of errors with the JavaScript
- (NSArray *)validateJavaScript:(NSString *)javaScript;

@end