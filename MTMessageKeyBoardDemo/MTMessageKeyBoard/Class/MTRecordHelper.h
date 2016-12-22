//
//  MTRecordHelper.h
//  MTMessageKeyBoardDemo
//
//  Created by 董徐维 on 2016/12/22.
//  Copyright © 2016年 Mr.Tung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTRecordHelper : NSObject


+ (MTRecordHelper *)shareRecordHelper;
-(void)startRecord;
-(void)stopRecord;


@property (nonatomic, copy) void (^recordEndBlock)(NSData *data);
@property (nonatomic, copy) void (^recordingBlock)(float recordTime,float volume);

@end
