//
//  PCParticleSelectViewController.m
//  SpriteBuilder
//
//  Created by Brendan Duddridge on 2014-03-12.
//
//

#import "PCParticleSelectViewController.h"
#import "PropertyInspectorTemplateCollectionView.h"

@interface PCParticleSelectViewController ()

@property (strong) IBOutlet PropertyInspectorTemplateCollectionView *particleCollectionView;

@end

@implementation PCParticleSelectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)loadView {
	[super loadView];
	[self.propertyInspectorHandler loadTemplateLibrary];
    self.particleCollectionView.isShortCutSelection = YES;
}

@end
