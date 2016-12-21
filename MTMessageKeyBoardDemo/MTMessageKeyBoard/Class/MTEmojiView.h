//
//  MTEmojiView.h
//  MTMessageKeyBoardDemo
//
//  Created by 董徐维 on 2016/12/21.
//  Copyright © 2016年 Mr.Tung. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTEmojiView;
@protocol EmojiViewDelegate <NSObject>
- (void)emojiView:(MTEmojiView *)emojiView emojiText:(NSObject *)text;
- (void)emojiView:(MTEmojiView *)emojiView sendButtonClick:(UIButton *)sender;
@end

@interface MTEmojiView : UIView


@property(nonatomic,weak) id<EmojiViewDelegate>delegate;

@end
