//
//  EmojiDataHelper.h
//  MTMessageKeyBoardDemo
//
//  Created by 董徐维 on 2016/12/21.
//  Copyright © 2016年 Mr.Tung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface EmojiDataHelper : NSObject

@property(nonatomic,strong)NSArray* emotions;

@property(nonatomic,strong)NSArray<UIImage*>* images;

- (void)initEmojiData;

+ (EmojiDataHelper *)shareEmojiData;

@end
