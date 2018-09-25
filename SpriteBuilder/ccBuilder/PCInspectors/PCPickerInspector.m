//
//  PCColorInspector.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-05-14.
//
//

#import "PCPickerInspector.h"
#import <Underscore.m/Underscore.h>

@interface PCPickerInspector ()

@property (weak, nonatomic) IBOutlet NSMenu *menu;
@property (strong, nonatomic) NSString *selectedOptionName;
@property (strong, nonatomic) NSArray *options;
@property (strong, nonatomic) NSArray *optionNames;

@end

@implementation PCPickerInspector

- (void)setValue:(id)value forValueInfoIndex:(NSInteger)index {
    self.selectedOptionName = [self nameForValue:value] ?: [self.optionNames firstObject];
}

#pragma mark - Private

- (id)valueForOptionName:(NSString *)name {
    NSDictionary *info = Underscore.array(self.options).find(^BOOL(NSDictionary *each) {
        return [each[@"name"] isEqualToString:name];
    });
    return info[@"value"];
}

- (NSString *)nameForValue:(id)value {
    NSDictionary *info = Underscore.array(self.options).find(^BOOL(NSDictionary *each) {
        return [each[@"value"] isEqual:value];
    });
    return info[@"name"];
}

- (id)value {
    return [self valueForOptionName:self.selectedOptionName];
}

- (void)dispatchValueChange {
    [self.delegate inspector:self valueChanged:[self value] forValueInfoAtIndex:0];
}

- (NSDictionary *)pickerValueInfo {
    return [[self valueInfos] firstObject];
}

- (void)updateOptions {
    self.options = [self pickerValueInfo][@"options"];
    self.optionNames = [self.options valueForKeyPath:@"name"];
}

#pragma mark - Properties

- (void)setValueInfos:(NSArray *)valueInfos {
    [super setValueInfos:valueInfos];
    [self updateOptions];
}

- (void)setSelectedOptionName:(NSString *)selectedOptionName {
    if (_selectedOptionName != selectedOptionName) {
        _selectedOptionName = selectedOptionName;
        [self dispatchValueChange];
    }
}

@end
