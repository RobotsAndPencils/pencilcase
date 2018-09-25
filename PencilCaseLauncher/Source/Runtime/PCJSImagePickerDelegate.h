//
//  PCJSImagePickerDelegate.h
//  
//
//  Created by Stephen Gazzard on 2015-02-25.
//
//

@import JavaScriptCore;

#import <Foundation/Foundation.h>

/**
 *   Kind of a weird animal here. When JS calls into +[PCContextPhotoLibrary showPhotoSelector...], we need to receive delegate callbacks from the photo picker. To handle this, we create this PCJSImagePickerDelegate object and have it sit around in memory until it receives a delegate callback from the UIImagePickerController. It stores the JSValue so that it can correctly inform Javascript to resume execution once the image picker has finished doing what it needs to do.
 */
@interface PCJSImagePickerDelegate : NSObject

+ (void)observeDelegateCallbacksFrom:(UIImagePickerController *)imagePickerController informingValueWhenFinished:(JSValue *)value;

@end
