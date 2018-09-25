//
//  PCTableCellInfo.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-05-08.
//
//

#import <Foundation/Foundation.h>

@class PCTableViewCell;

@interface PCTableCellInfo : NSObject <NSCoding>

@property (strong, nonatomic, readonly) NSString *uuid;

- (CGRect)baseFrame;
- (CGFloat)height;
- (NSString *)reuseIdentifier;

- (id)createViewsForTableCell:(PCTableViewCell *)cell; // returns a view loader object that must be passed to loadValuesUsingViewMapping:
- (void)loadValuesUsingViewMapping:(id)viewLoader;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)cellInfoWithTitle:(NSString *)title accessoryType:(UITableViewCellAccessoryType)accessoryType;
+ (instancetype)cellInfoWithTitle:(NSString *)title detail:(NSString *)detail accessoryType:(UITableViewCellAccessoryType)accessoryType;
+ (instancetype)cellInfoWithTitle:(NSString *)title imagePath:(NSString *)imagePath accessoryType:(UITableViewCellAccessoryType)accessoryType;

@end
