//
//  PCResponderView.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-06-16.
//
//

#import "PCViewControllerResponderView.h"

@interface PCViewControllerResponderView()

@property (strong, nonatomic) IBOutlet NSViewController *viewController;

@end


@implementation PCViewControllerResponderView

- (void)setViewController:(NSViewController *)newController {
    // NOTE: only used to check if we are running on OSX 10.10 or later.
    //       NSViewControllers are now part of the responder chain in 10.10
    //       and up.
    if ([self respondsToSelector:@selector(viewWillAppear)]) {
        return;
    }
        
    if (_viewController) {
        NSResponder *controllerNextResponder = [_viewController nextResponder];
        [super setNextResponder:controllerNextResponder];
        [_viewController setNextResponder:nil];
    }
    
    _viewController = newController;
    
    if (newController) {
        NSResponder *ownNextResponder = [self nextResponder];
        [super setNextResponder: self.viewController];
        [self.viewController setNextResponder:ownNextResponder];
    }
}

- (void)setNextResponder:(NSResponder *)newNextResponder
{
    if (_viewController) {
        [_viewController setNextResponder:newNextResponder];
        return;
    }
    
    [super setNextResponder:newNextResponder];
}

@end
