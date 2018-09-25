//
//  SKNode+GestureRecognizers.m
//  Kubik
//
//  Created by Krzysztof Zablocki on 2/12/12.
//  Copyright (c) 2012 Krzysztof Zablocki. All rights reserved.
//
//
//  ARC Helper
//
//  Version 1.2.2
//
//  Created by Nick Lockwood on 05/01/2012.
//  Copyright 2012 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://gist.github.com/1563325

//  Krzysztof Zabłocki Added (__bridge void *)(x) to bridge cast to void*

#import "SKNode+SFGestureRecognizers.h"
#import <objc/runtime.h>
#import "SKNode+GeneralHelpers.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+CoordinateConversion.h"
#import "PCAppViewController.h"
#import "SKNode+LifeCycle.h"
#import "PCMathUtilities.h"

//! __ for internal use | check out SFExecuteOnDealloc for category on NSObject that allows the same ;)
typedef void(^__SFExecuteOnDeallocBlock)(void);

@interface __SFExecuteOnDealloc : NSObject
+ (id)executeBlock:(__SFExecuteOnDeallocBlock)aBlock onObjectDealloc:(id)aObject;

- (id)initWithBlock:(__SFExecuteOnDeallocBlock)aBlock;
@end

@implementation __SFExecuteOnDealloc {
@public
  __SFExecuteOnDeallocBlock block;
}

+ (id)executeBlock:(__SFExecuteOnDeallocBlock)aBlock onObjectDealloc:(id)aObject
{
  __SFExecuteOnDealloc *executor = [[self alloc] initWithBlock:aBlock];
  objc_setAssociatedObject(aObject, (__bridge void *)executor, executor, OBJC_ASSOCIATION_RETAIN);
  return executor;
}

- (id)initWithBlock:(__SFExecuteOnDeallocBlock)aBlock
{
  self = [super init];
  if (self) {
    block = [aBlock copy];
  }
  return self;
}

- (void)dealloc
{
  if (block) {
    block();
  }
}
@end


static NSString *const SKNodeSFGestureRecognizersArrayKey = @"SKNodeSFGestureRecognizersArrayKey";
static NSString *const SKNodeSFGestureRecognizersTouchRect = @"SKNodeSFGestureRecognizersTouchRect";
static NSString *const SKNodeSFGestureRecognizersTouchEnabled = @"SKNodeSFGestureRecognizersTouchEnabled";
static NSString *const UIGestureRecognizerSFGestureRecognizersPassingDelegateKey = @"UIGestureRecognizerSFGestureRecognizersPassingDelegateKey";

@interface __SFGestureRecognizersPassingDelegate : NSObject <UIGestureRecognizerDelegate> {
@public
  __weak id <UIGestureRecognizerDelegate> originalDelegate;
  __weak SKNode *node;
  void *deallocBlockKey;
}
@end

@implementation __SFGestureRecognizersPassingDelegate

#pragma mark - UIGestureRecognizer Delegate handling
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
  SKView *view = node.pc_scene.view;
  CGPoint pt = [view convertPoint:[touch locationInView:view] toScene:view.scene];
  BOOL rslt = [node sf_isPointTouchableInArea:pt];

  //! we need to make sure that no other node ABOVE this one was touched, we want ONLY the top node with gesture recognizer to get callback
  if (rslt) {
    SKNode *curNode = node;
    SKNode *parent = node.parent;

    while (curNode != nil && rslt) {

      //! we also need to make sure there is no crop node that is cropping us
      if ([parent isKindOfClass:[SKCropNode class]] && ![parent sf_isPointInArea:pt]) {
        rslt = NO;
      }

      BOOL nodeFound = NO;
      for (SKNode *child in parent.children){
        // Skip nodes earlier than `node` in subview list - this should probably use z order though
        if (!nodeFound) {
          if (!nodeFound && curNode == child) {
            nodeFound = YES;
          }
          continue;
        }
        if( [child sf_isNodeInTreeTouched:pt])
        {
          rslt = NO;
          break;
        }
      }

      curNode = parent;
      parent = curNode.parent;
    }
  }

  if (rslt && [originalDelegate respondsToSelector:@selector(gestureRecognizer:shouldReceiveTouch:)]) {
    rslt = [originalDelegate gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
  }

  return rslt;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
  if ([originalDelegate respondsToSelector:@selector(gestureRecognizerShouldBegin:)]) {
    return [originalDelegate gestureRecognizerShouldBegin:gestureRecognizer];
  }
  return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
  if ([originalDelegate respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)]) {
    return [originalDelegate gestureRecognizer:gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:otherGestureRecognizer];
  }

  return YES;
}

#pragma mark - Handling delegate change
- (void)setDelegate:(id <UIGestureRecognizerDelegate>)aDelegate
{
  __SFGestureRecognizersPassingDelegate *passingDelegate = objc_getAssociatedObject(self, (__bridge void *)(UIGestureRecognizerSFGestureRecognizersPassingDelegateKey));
  if (passingDelegate) {
    passingDelegate->originalDelegate = aDelegate;
  } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self performSelector:@selector(originalSetDelegate:) withObject:aDelegate];
#pragma clang diagnostic pop
  }
}

- (id <UIGestureRecognizerDelegate>)delegate
{
  __SFGestureRecognizersPassingDelegate *passingDelegate = objc_getAssociatedObject(self, (__bridge void *)(UIGestureRecognizerSFGestureRecognizersPassingDelegateKey));
  if (passingDelegate) {
    return passingDelegate->originalDelegate;
  }

  //! no delegate yet so use original method
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
  return [self performSelector:@selector(originalDelegate)];
#pragma clang diagnostic pop
}

- (Class)swappedClass
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
  Class originalClass = [self performSelector:@selector(originalClass)];
#pragma clang diagnostic pop
  NSString *gestureClassString = NSStringFromClass(originalClass);
  if ([gestureClassString hasPrefix:kSFGestureClassPrefix]) {
    originalClass = NSClassFromString([gestureClassString stringByReplacingOccurrencesOfString:kSFGestureClassPrefix withString:@""]);
  }
  return originalClass;
}

@end


@implementation UIGestureRecognizer (SFGestureRecognizers)
@dynamic sf_node;

- (SKNode*)sf_node
{
  __SFGestureRecognizersPassingDelegate *passingDelegate = objc_getAssociatedObject(self, (__bridge void *)(UIGestureRecognizerSFGestureRecognizersPassingDelegateKey));
  if (passingDelegate) {
    return passingDelegate->node;
  }
  return nil;
}
@end


@implementation SKNode (SFGestureRecognizers)

@dynamic sf_isTouchEnabled;
@dynamic sf_touchRect;

- (void)sf_addGestureRecognizer:(UIGestureRecognizer*)aGestureRecognizer
{
  //! prepare passing gesture recognizer
  __SFGestureRecognizersPassingDelegate *passingDelegate = [[__SFGestureRecognizersPassingDelegate alloc] init];
  passingDelegate->originalDelegate = aGestureRecognizer.delegate;
  passingDelegate->node = self;
  aGestureRecognizer.delegate = passingDelegate;
  //! retain passing delegate as it only lives as long as this gesture recognizer lives
  objc_setAssociatedObject(aGestureRecognizer, (__bridge void *)(UIGestureRecognizerSFGestureRecognizersPassingDelegateKey), passingDelegate, OBJC_ASSOCIATION_RETAIN);

  //! we need to swap gesture recognizer methods so that we can handle delegates nicely
  //! let's not modify global classes, it's safer to implement new class for this gesture recognizer

  NSString *gestureClassString = NSStringFromClass([aGestureRecognizer class]);
  if (![gestureClassString hasPrefix:kSFGestureClassPrefix]) {
    NSString *subclassName = [NSString stringWithFormat:@"sfg_%@", gestureClassString];
    Class newClass = NSClassFromString(subclassName);
    if (!newClass) {
      newClass = objc_allocateClassPair([aGestureRecognizer class], [subclassName UTF8String], 0);
      objc_registerClassPair(newClass);

      Method originalGetter = class_getInstanceMethod(newClass, @selector(delegate));
      Method originalSetter = class_getInstanceMethod(newClass, @selector(setDelegate:));
      Method originalClass = class_getInstanceMethod(newClass, @selector(class));

      Method swappedGetter = class_getInstanceMethod([__SFGestureRecognizersPassingDelegate class], @selector(delegate));
      Method swappedSetter = class_getInstanceMethod([__SFGestureRecognizersPassingDelegate class], @selector(setDelegate:));
      Method swappedClass = class_getInstanceMethod([__SFGestureRecognizersPassingDelegate class], @selector(swappedClass));

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
      class_addMethod(newClass, @selector(originalDelegate), method_getImplementation(originalGetter), method_getTypeEncoding(originalGetter));
      class_replaceMethod(newClass, @selector(delegate), method_getImplementation(swappedGetter), method_getTypeEncoding(swappedGetter));
      
      class_addMethod(newClass, @selector(originalSetDelegate:), method_getImplementation(originalSetter), method_getTypeEncoding(originalSetter));
      class_replaceMethod(newClass, @selector(setDelegate:), method_getImplementation(swappedSetter), method_getTypeEncoding(swappedSetter));
      
      class_addMethod(newClass, @selector(originalClass), method_getImplementation(originalClass), method_getTypeEncoding(originalClass));
      class_replaceMethod(newClass, @selector(class), method_getImplementation(swappedClass), method_getTypeEncoding(swappedClass));

#pragma clang diagnostic pop
    }
    object_setClass(aGestureRecognizer, newClass);
  }

    SKView *view = self.pc_scene.view;
    [view addGestureRecognizer:aGestureRecognizer];

  //! add to array
  NSMutableArray *gestureRecognizers = objc_getAssociatedObject(self, (__bridge void *)(SKNodeSFGestureRecognizersArrayKey));
  if (!gestureRecognizers) {
    gestureRecognizers = [NSMutableArray array];
    objc_setAssociatedObject(self, (__bridge void *)(SKNodeSFGestureRecognizersArrayKey), gestureRecognizers, OBJC_ASSOCIATION_RETAIN);

  }
  [gestureRecognizers addObject:aGestureRecognizer];

  //! remove this gesture recognizer from view when array is deallocatd
  __unsafe_unretained __block SKNode *weakSelf = self;
  void *key = (__bridge void *)([__SFExecuteOnDealloc executeBlock:^{
     aGestureRecognizer.delegate = nil;
    [weakSelf sf_removeGestureRecognizer:aGestureRecognizer];
  } onObjectDealloc:gestureRecognizers]);

  //! remember dealloc block key
  passingDelegate->deallocBlockKey = key;

    [self sf_setIsTouchEnabled:self.userInteractionEnabled];
}

- (void)sf_removeGestureRecognizer:(UIGestureRecognizer*)aGestureRecognizer
{
  NSMutableArray *gestureRecognizers = objc_getAssociatedObject(self, (__bridge void *)(SKNodeSFGestureRecognizersArrayKey));

  //! remove dealloc block
  __SFGestureRecognizersPassingDelegate *delegate = objc_getAssociatedObject(aGestureRecognizer, (__bridge void *)(UIGestureRecognizerSFGestureRecognizersPassingDelegateKey));
  objc_setAssociatedObject(gestureRecognizers, delegate->deallocBlockKey, nil, OBJC_ASSOCIATION_ASSIGN);
    
  id realDelegate = delegate->originalDelegate;
  objc_setAssociatedObject(aGestureRecognizer, (__bridge void *)(UIGestureRecognizerSFGestureRecognizersPassingDelegateKey), nil, OBJC_ASSOCIATION_RETAIN);
  aGestureRecognizer.delegate = realDelegate;

    [aGestureRecognizer.view removeGestureRecognizer:aGestureRecognizer];
  
  //! restore original class
  NSString *gestureClassString = NSStringFromClass(object_getClass(aGestureRecognizer));
  if ([gestureClassString hasPrefix:kSFGestureClassPrefix]) {
    Class originalClass = NSClassFromString([gestureClassString stringByReplacingOccurrencesOfString:kSFGestureClassPrefix withString:@""]);
    object_setClass(aGestureRecognizer, originalClass);
  }

  [gestureRecognizers removeObject:aGestureRecognizer];
}

- (NSArray*)sf_gestureRecognizers
{
  //! add to array
  NSMutableArray *gestureRecognizers = objc_getAssociatedObject(self, (__bridge void *)(SKNodeSFGestureRecognizersArrayKey));
  if (!gestureRecognizers) {
    gestureRecognizers = [NSMutableArray array];
    objc_setAssociatedObject(self, (__bridge void *)(SKNodeSFGestureRecognizersArrayKey), gestureRecognizers, OBJC_ASSOCIATION_RETAIN);
  }
  return [NSArray arrayWithArray:gestureRecognizers];
}

#pragma mark - Point inside

- (BOOL)sf_isPointInArea:(CGPoint)pt
{
  if (!self.visible || self.anyParentNotVisible) {
    return NO;
  }

  //! convert to local space
  pt = [self pc_convertToNodeSpace:pt];

  //! get touchable rect in local space
  CGRect rect = self.sf_touchRect;

  if (CGRectContainsPoint(rect, pt)) {
    return YES;
  }
  return NO;
}

- (BOOL)sf_isPointTouchableInArea:(CGPoint)pt
{
  if (!self.sf_isTouchEnabled) {
    return NO;
  } else {
    return [self sf_isPointInArea:pt];
  }
}

- (BOOL)sf_isNodeInTreeTouched:(CGPoint)pt
{
  if( [self sf_isPointTouchableInArea:pt] ) {
    return YES;
  }

    if ([self isKindOfClass:[SKCropNode class]]) {
        return NO;
    }

  BOOL rslt = NO;
  for (SKNode *child in self.children){
    if( [child sf_isNodeInTreeTouched:pt] )
  {
    rslt = YES;
    break;
  }
}
  return rslt;
}

#pragma mark - Touch Enabled

- (BOOL)sf_isTouchEnabled
{
    return self.userInteractionEnabled;
}

- (void)sf_setIsTouchEnabled:(BOOL)aTouchEnabled
{
    self.userInteractionEnabled = aTouchEnabled;
}

#pragma mark - Touch Rectangle

- (void)sf_setTouchRect:(CGRect)aRect
{
  objc_setAssociatedObject(self, (__bridge void *)(SKNodeSFGestureRecognizersTouchRect), [NSValue valueWithCGRect:aRect], OBJC_ASSOCIATION_RETAIN);
}

- (CGRect)sf_touchRect {
    NSValue *rectValue = objc_getAssociatedObject(self, (__bridge void *)(SKNodeSFGestureRecognizersTouchRect));
    if (rectValue) {
        return [rectValue CGRectValue];
    } else {
        if ([self isKindOfClass:[SKCropNode class]]) {
            return [(SKCropNode *)self maskNode].sf_touchRect;
        }
        CGRect defaultRect = CGRectMake(-self.anchorPoint.x * fabsf(self.contentSize.width),
                                        -self.anchorPoint.y * fabsf(self.contentSize.height),
                                        fabsf(self.contentSize.width), fabsf(self.contentSize.height));
        self.sf_touchRect = defaultRect;
        return defaultRect;
    }
}

@end
