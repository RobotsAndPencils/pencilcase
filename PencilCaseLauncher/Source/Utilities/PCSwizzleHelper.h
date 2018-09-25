//
//  PCSwizzleHelper.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-15.
//
//
#import <objc/runtime.h>

#pragma mark - Helper for Swizzling. Not to be used without approval from somebody else on the team.
// http://petersteinberger.com/blog/2014/a-story-about-swizzling-the-right-way-and-touch-forwarding/

static IMP PCReplaceMethodWithBlock(Class c, SEL origSEL, id block) {
    NSCParameterAssert(block);
    
    // get original method
    Method origMethod = class_getInstanceMethod(c, origSEL);
    NSCParameterAssert(origMethod);
    
    // convert block to IMP trampoline and replace method implementation
    IMP newIMP = imp_implementationWithBlock(block);
    
    // Try adding the method if not yet in the current class
    if (!class_addMethod(c, origSEL, newIMP, method_getTypeEncoding(origMethod))) {
        return method_setImplementation(origMethod, newIMP);
    }else {
        return method_getImplementation(origMethod);
    }
}