//
//  MoreCollectionViewCell.m
//  MTMessageKeyBoardDemo
//
//  Created by 董徐维 on 2016/12/21.
//  Copyright © 2016年 Mr.Tung. All rights reserved.
//

#import "MoreCollectionViewCell.h"

#define kImagePadding 20

@interface MoreCollectionViewCell ()
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)UILabel *label;

@end

@implementation MoreCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.imageView = [[UIImageView alloc] init];
    self.imageView.frame = CGRectMake(kImagePadding, 10, self.frame.size.width - kImagePadding *2,  self.frame.size.width - kImagePadding *2);
    self.label = [[UILabel alloc] init];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont systemFontOfSize:12];
    self.label.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame) + 5, self.frame.size.width, 15);

    [self addSubview:self.imageView];
    [self addSubview:self.label];
}

- (void)setString:(NSString *)string
{
    self.label.text = string;
}

- (void)setImage:(UIImage *)image
{
    self.imageView.image = image;
}

@end
