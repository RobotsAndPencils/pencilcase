//
//  PCSoundFilePublisher.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-07-06.
//
//

#import "PCFilePublisher.h"
#import "PCFileRenameRulePublisher.h"

@interface PCSoundFilePublisher : PCFilePublisher <PCFileRenameRulePublisher>

+ (PCSoundFilePublisher *)soundFilePublisher;

@end
