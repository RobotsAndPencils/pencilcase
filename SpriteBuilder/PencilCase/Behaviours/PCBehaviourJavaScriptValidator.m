//
// Created by Brandon Evans on 15-03-20.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "PCBehaviourJavaScriptValidator.h"
#import "PCBehaviourJavaScriptError.h"

NSString * const PCBehaviourJavaScriptErrorCodeYieldOutsideGeneratorFunction = @"E046";

@interface PCBehaviourJavaScriptValidator ()

@property (nonatomic, strong) JSContext *javaScriptContext;

@end

@implementation PCBehaviourJavaScriptValidator

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.javaScriptContext = [[JSContext alloc] init];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"jshint" ofType:@"js"];
    NSError *jsHintLoadError;
    NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&jsHintLoadError];
    if (jsHintLoadError) {
        PCLog(@"Error loading JSHint for JavaScript validation: %@", jsHintLoadError);
        // This won't be very useful without it
        return nil;
    }
    [self.javaScriptContext evaluateScript:contents withSourceURL:[NSURL URLWithString:path]];

    return self;
}

- (NSArray *)validateJavaScript:(NSString *)javaScript {
    JSValue *jsHint = self.javaScriptContext[@"JSHINT"];
    [jsHint callWithArguments:@[javaScript, @{ @"esnext": @YES, @"asi": @YES, @"eqeqeq": @NO }]];
    JSValue *results = [jsHint invokeMethod:@"data" withArguments:@[]];
    NSArray *errorInfo = [results toDictionary][@"errors"];
    NSArray *errors = Underscore.array(errorInfo).filter(^BOOL(NSDictionary *eachErrorInfo) {
        if (PCIsEmpty(eachErrorInfo)) {
            return NO;
        }
        
        BOOL errorIsYieldOutsideGeneratorFunction = [eachErrorInfo[@"code"] isEqualToString:PCBehaviourJavaScriptErrorCodeYieldOutsideGeneratorFunction];
        return !errorIsYieldOutsideGeneratorFunction;
    }).map(^PCBehaviourJavaScriptError *(NSDictionary *eachErrorInfo) {
        PCBehaviourJavaScriptError *error = [[PCBehaviourJavaScriptError alloc] init];
        error.lineNumber = [eachErrorInfo[@"line"] unsignedIntegerValue];
        error.column = [eachErrorInfo[@"character"] unsignedIntegerValue];
        error.errorMessage = [NSString stringWithFormat:@"\"%@\" %@", eachErrorInfo[@"evidence"], eachErrorInfo[@"reason"]];
        return error;
    }).unwrap;
    return errors;
}

@end
