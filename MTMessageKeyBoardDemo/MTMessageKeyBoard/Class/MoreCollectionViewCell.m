//
//  MoreCollectionViewCell.m
//  MTMessageKeyBoardDemo
//
//  Created by 董徐维 on 2016/12/21.
//  Copyright © 2016年 Mr.Tung. All rights reserved.
//

#import "MoreCollectionViewCell.h"

@interface MoreCollectionViewCell ()
@property (nonatomic,strong)UIButton *button;
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
    self.button = [[UIButton alloc] init];
    self.button.frame = CGRectMake(0, -20, self.frame.size.width,  self.frame.size.width);

    self.label = [[UILabel alloc] init];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.font = [UIFont systemFontOfSize:12];
    self.label.frame = CGRectMake(0, CGRectGetMaxY(self.button.frame) - 20, self.frame.size.width, 15);

    self.button.userInteractionEnabled = false;
    [self addSubview:self.button];
    [self addSubview:self.label];
}

- (void)setString:(NSString *)string
{
    self.label.text = string;
}

- (void)setImage:(UIImage *)image
{
    [self.button setImage:image forState:UIControlStateNormal];
    [self.button setImage:image forState:UIControlStateHighlighted];
}

@end
