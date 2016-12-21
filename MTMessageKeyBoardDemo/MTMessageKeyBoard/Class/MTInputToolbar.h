//
//  MTInputToolbar.h
//  MTMessageKeyBoardDemo
//
//  Created by 董徐维 on 2016/12/21.
//  Copyright © 2016年 Mr.Tung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTInputToolbar : UIView

/**
 *  初始化chat bar
 */
- (instancetype)initWithFrame:(CGRect)frame;

/**
 *  设置输入框最大行数
 */
@property (nonatomic,assign)NSInteger textViewMaxLine;
@end
