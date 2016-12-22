//
//  MTRecordHelper.m
//  MTMessageKeyBoardDemo
//
//  Created by 董徐维 on 2016/12/22.
//  Copyright © 2016年 Mr.Tung. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "MTRecordHelper.h"
#import "Mp3Recorder.h"
#import "lame.h"
#import <AVFoundation/AVFoundation.h>

@interface MTRecordHelper()<Mp3RecorderDelegate>
{
    
    int maxTime;
    Mp3Recorder *mp3;
}
@end
@implementation MTRecordHelper


+ (MTRecordHelper *)shareRecordHelper
{
    static MTRecordHelper *shareRecordHelper = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        shareRecordHelper = [[self alloc] init];
    });
    return shareRecordHelper;
}

-(void)startRecord
{
    maxTime = 60;
    mp3 = [[Mp3Recorder alloc]initWithDelegate:self];
    [mp3 startRecord];
}

-(void)stopRecord
{
    [mp3 stopRecord];
}


#pragma mark Mp3RecordDelegate
-(void)beginConvert
{
    
}

//录音失败
- (void)failRecord
{
    
}


//回调录音资料
- (void)endConvertWithData:(NSData *)voiceData
{
    if (self.recordEndBlock) {
        self.recordEndBlock(voiceData);
    }
}

-(void)recording:(float)recordTime volume:(float)volume
{
    if (recordTime>=maxTime) {
        [self stopRecord];
    }
    NSLog(@"%@", [NSString stringWithFormat:@"mic_%.0f.png",volume*10 > 5 ? 5 : volume*10]);
    
    if (self.recordingBlock) {
        self.recordingBlock(recordTime,volume);
    }
//    [RecordHUD setImage:[NSString stringWithFormat:@"mic_%.0f.png",volume*10 > 5 ? 5 : volume*10]];
//    [RecordHUD setTimeTitle:[NSString stringWithFormat:@"录音: %.0f\"",recordTime]];
}


@end
