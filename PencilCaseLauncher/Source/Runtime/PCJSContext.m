//
//  PCJSContext.m
//  
//
//  Created by Brandon Evans on 2014-12-17.
//
//

#import "PCContextCreation.h"
#import "PCJSContext.h"
#import "PCContextSound.h"
#import "PCAppViewController.h"
#import "PCContextPhotoLibrary.h"
#import "PCApp.h"
#import "PCContextData.h"

NSString * const PCJSContextEventNotificationName = @"PCJSContextEventNotificationName";
NSString * const PCJSContextEventNotificationEventNameKey = @"PCJSContextEventNotificationEventNameKey";
NSString * const PCJSContextEventNotificationArgumentsKey = @"PCJSContextEventNotificationArgumentsKey";

@implementation PCJSContext

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    // This shouldn't be used for anything other than getting dynamic access to classes
    // It's used in Creation.createObject('ObjectClassName') to be able to do: `var newObject = Global[objectClassName];`
    self[@"Global"] = self.globalObject;

    [self evaluateScriptFileWithName:@"lodash"];
    [self evaluateScriptFileWithName:@"EventEmitter"];
    [self requireModules:@[ @"co" ]];
    [self evaluateScript:@"var Event = new EventEmitter();"];
    [self evaluateScript:@"var extendNonEnumerable = require('extendNonEnumerable').extendNonEnumerable;"];
    // This makes the EventEmitter properties available to all Objects (which is also the prototype of bridged NSObjects)
    // This is used for two-way data binding between arbitrary objects
    // We extend Object.prototype with non-enumerable properties so that passing a JS Object to native code doesn't result
    // in a dictionary with a bunch of EventEmitter properties in it.
    // e.g. Otherwise  { x: 20 } would become @{ @"x": @20, @"trigger": JSValue, ... }
    [self evaluateScript:@"extendNonEnumerable(Object.prototype, EventEmitter.prototype)"];
    [self evaluateScript:@"require('bind');"
                          "require('watch');"];

    // Keys are the exported JS name, values are the native classes to export (which should have a JSExport category if you want it to be useful)
    NSDictionary *classExportMap = @{
        @"BaseObject": @"SKNode",
        @"ColorView": @"PCNodeColor",
        @"Color": @"UIColor",
        @"Control": @"PCControl",
        @"ParticleSystem": @"PCParticleSystem",
        @"ImageView": @"PCSprite",
        @"Label": @"PCLabelTTF",
        @"UUID": @"NSUUID",
        @"Alert": @"UIAlertView",
        @"ActivityView": @"UIActivityViewController",
        @"Button": @"PCButton",
        @"Texture": @"SKTexture",
        @"Beacon": @"PCIBeacon",
        @"GradientView": @"PCNodeGradient",
        @"TextField": @"PCTextField",
        @"ThreeDView": @"PC3DNode",
        @"CameraCaptureView": @"PCCameraCaptureNode",
        @"FingerPaintView": @"PCFingerPaintView",
        @"ForceObject": @"PCForceNode",
        @"MultiViewCell": @"PCMultiViewCellNode",
        @"MultiView": @"PCMultiViewNode",
        @"ScrollContentView": @"PCScrollContentNode",
        @"ScrollView": @"PCScrollViewNode",
        @"Shape": @"PCShapeNode",
        @"CardObject": @"PCSlideNode",
        @"Switch": @"PCSwitchNode",
        @"Slider": @"PCSliderNode",
        @"TableView": @"PCTableNode",
        @"TableCellInfo": @"PCTableCellInfo",
        @"TextInput": @"PCTextInputView",
        @"TextBox": @"PCTextView",
        @"VideoView": @"PCVideoPlayer",
        @"WebView": @"PCWebViewNode",
        @"ResourceManager": @"PCResourceManager",
        @"Filter": @"CIFilter",
        @"Image": @"UIImage",
        @"MailComposer": @"PCMailComposeController",
        @"Data": @"NSData",
        @"MarkdownParser": @"PCMarkdownParser",
    };
    for (NSString *javaScriptName in classExportMap) {
        NSString *className = classExportMap[javaScriptName];
        [self evaluateScript:[NSString stringWithFormat:@"var %@ = require('%@');", javaScriptName, className]];
    }

    self[@"KeyValueStore"] = [PCAppViewController lastCreatedInstance].runningApp.keyValueStore;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyValueStoreChanged:) name:@"PCKeyValueStoreDidChange" object:nil];

    [PCContextCreation setupInContext:self];
    [self evaluateScript:@"var Creation = require('creation');"];
    [PCContextSound setupInContext:self];
    [self evaluateScript:@"var Sound = require('sound');"];
    [self evaluateScript:@"var Request = require('request');"];
    [PCContextPhotoLibrary setupInContext:self];
    [self evaluateScript:@"var PhotoLibrary = require('photolibrary');"];
    [PCContextData setupInContext:self];

    // clobber eval for security reasons
    [self evaluateScript:@"eval = undefined;"];

    return self;
}

- (void)keyValueStoreChanged:(NSNotification *)notification {
    self[@"KeyValueStore"] = notification.userInfo[@"keyValueStore"];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"PCKeyValueStoreDidChange" object:nil];
}

#pragma mark - Events

- (void)triggerEventWithName:(NSString *)name {
    [self triggerEventWithName:name arguments:@[]];
}

- (void)triggerEventWithName:(NSString *)name arguments:(NSArray *)arguments {
    [self triggerEventWithName:name arguments:arguments loggingEnabled:YES];
}

- (void)triggerEventWithName:(NSString *)name arguments:(NSArray *)arguments loggingEnabled:(BOOL)loggingEnabled {
    if (!arguments) arguments = @[];
    if (loggingEnabled) {
        PCLog(@"Triggering global event '%@'", name);
    }

    JSValue *eventObject = self[@"Event"];
    [eventObject invokeMethod:@"trigger" withArguments:@[ name, arguments ]];
}

- (void)triggerEventOnJavaScriptRepresentation:(NSString *)javaScriptRepresentation eventName:(NSString *)eventName {
    [self triggerEventOnJavaScriptRepresentation:javaScriptRepresentation eventName:eventName arguments:@[ ]];
}

- (void)triggerEventOnJavaScriptRepresentation:(NSString *)javaScriptRepresentation eventName:(NSString *)eventName arguments:(NSArray *)arguments {
    [self triggerEventOnJavaScriptRepresentation:javaScriptRepresentation eventName:eventName arguments:arguments loggingEnabled:YES];
}

- (void)triggerEventOnJavaScriptRepresentation:(NSString *)javaScriptRepresentation eventName:(NSString *)eventName arguments:(NSArray *)arguments loggingEnabled:(BOOL)loggingEnabled {
    if (!arguments) arguments = @[];
    JSValue *instance = [self evaluateScript:javaScriptRepresentation];
    if (!instance) return;
    if (loggingEnabled) {
        PCLog(@"Instance '%@' triggering event '%@'", javaScriptRepresentation, eventName);
    }
    NSArray *preparedArguments = [self prepareArguments:arguments];
    [instance invokeMethod:@"trigger" withArguments:@[ eventName, preparedArguments ]];
}

// :( So invokeMethod:withArguments: won't automatically unwrap NSValues and turn them into JSValues for us
// We do that ourselves here instead, because the context will do the right thing if we give it a JSValue instead
// This was found by looking at the source for the method
- (NSArray *)prepareArguments:(NSArray *)arguments {
    NSArray *preparedArguments = @[];
    id preparedArgument;
    for (id argument in arguments) {
        // Things like __NSCFNumber return YES for isKindOfClass:[NSValue class]]
        // This is the class that's used for wrapped points, so check against it instead
        if ([argument isKindOfClass:NSClassFromString(@"NSConcreteValue")]) {
            NSValue *value = (NSValue *)argument;
            // We're just supporting the structs that JSValue supports by default
            // If we add more of our own we'll have to add them here too
            if (strcmp(value.objCType, @encode(CGPoint)) == 0) {
                preparedArgument = [JSValue valueWithPoint:value.CGPointValue inContext:self];
            }
            if (strcmp(value.objCType, @encode(CGRect)) == 0) {
                preparedArgument = [JSValue valueWithRect:value.CGRectValue inContext:self];
            }
            if (strcmp(value.objCType, @encode(CGSize)) == 0) {
                preparedArgument = [JSValue valueWithSize:value.CGSizeValue inContext:self];
            }
        }
        else {
            preparedArgument = argument;
        }

        if (preparedArgument) {
            preparedArguments = [preparedArguments arrayByAddingObject:preparedArgument];
        }
    }
    return preparedArguments;
}

- (void)tearDown {
    JSValue *eventObject = self[@"Event"];
    [eventObject invokeMethod:@"removeAllListeners" withArguments:@[]];
}

@end
