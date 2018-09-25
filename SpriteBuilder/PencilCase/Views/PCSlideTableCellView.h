//
//  PCSlideTableCellView.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 1/23/2014.
//
//

@interface PCSlideTableCellView : NSTableCellView

@property (nonatomic, assign) NSInteger slideIndex;
@property (nonatomic, strong) NSImage *slideThumbnail;
@property (nonatomic, strong) NSString *slideUUID;

@end
