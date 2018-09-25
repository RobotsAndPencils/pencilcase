//
//  PropertyInspectorHandler.h
//  CocosBuilder
//
//  Created by Viktor on 7/29/13.
//
//

#import <Cocoa/Cocoa.h>

@class PCTemplateLibrary;
@class PCTemplate;

@interface PropertyInspectorHandler : NSObject <NSCollectionViewDelegate> {
    IBOutlet PCTemplateLibrary *templateLibrary;
    IBOutlet NSCollectionView *collectionView;

    IBOutlet NSTextField *newTemplateName;
    IBOutlet NSColorWell *newTemplateBgColor;

    IBOutlet NSButton *newTemplateCreateButton;
}

- (void)updateTemplates;
- (void)updateTemplatesForNodeType:(NSString *)plugInName;

- (IBAction)addTemplate:(id)sender;
- (void)removeTemplate:(PCTemplate *)templ;
- (void)applyTemplate:(PCTemplate *)templ;

- (void)loadTemplateLibrary;

@end
