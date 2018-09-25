//
// Created by Brandon Evans on 15-03-20.
//

@interface PCBehaviourJavaScriptError : NSObject

@property (nonatomic, assign) NSUInteger lineNumber;
@property (nonatomic, assign) NSUInteger column;
@property (nonatomic, assign) NSString *errorMessage;

@end