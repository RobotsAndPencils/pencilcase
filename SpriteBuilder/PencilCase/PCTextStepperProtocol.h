//
//  PCTextStepperProtocol.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-06-24.
//
//

#import <Foundation/Foundation.h>

@protocol PCTextStepperProtocol <NSObject>

- (void)setStepAmount:(CGFloat)stepAmount;

@optional
- (void)setFormatter:(NSNumberFormatter *)formatter;

@end
