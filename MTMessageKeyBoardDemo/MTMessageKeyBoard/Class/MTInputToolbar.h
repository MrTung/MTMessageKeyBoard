//
//  MTInputToolbar.h
//  MTMessageKeyBoardDemo
//
//  Created by 董徐维 on 2016/12/21.
//  Copyright © 2016年 Mr.Tung. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTInputToolbar;

@protocol MTInputToolbarDelegate <NSObject>

- (void)inputToolbar:(MTInputToolbar *)inputToolbar sendContent:(NSAttributedString *)sendContent;

- (void)inputToolbar:(MTInputToolbar *)inputToolbar sendRecordData:(NSData *)Data;

- (void)inputToolbar:(MTInputToolbar *)inputToolbar indexPath:(NSIndexPath *)indexPath;


@end

@interface MTInputToolbar : UIView

/**
 *  初始化chat bar
 */
- (instancetype)initWithFrame:(CGRect)frame;

/**
 *  设置输入框最大行数
 */
@property (nonatomic,assign)NSInteger textViewMaxLine;

/**
 *  设置更多界面的数据源(格式为:字典数组。包含2个字段：@image , @label)
 */
@property (strong, nonatomic)NSArray <NSDictionary<NSString *,NSString*> *> *typeDatas;

@property (nonatomic,weak) id<MTInputToolbarDelegate>delegate;

@end
