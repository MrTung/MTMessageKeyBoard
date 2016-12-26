//
//  ViewController.m
//  MTMessageKeyBoardDemo
//
//  Created by 董徐维 on 2016/12/21.
//  Copyright © 2016年 Mr.Tung. All rights reserved.
//


#define MTScreenW [UIScreen mainScreen].bounds.size.width

#define MTScreenH [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"

#import "MTInputToolbar.h"

@interface ViewController ()<MTInputToolbarDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MTInputToolbar *inputToolbar = [[MTInputToolbar alloc] initWithFrame:CGRectMake(0,MTScreenH - 50 , MTScreenW, 50)];
    inputToolbar.delegate = self;
    //文本输入框最大行数
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (int i = 0; i<12; i ++ ) {
        NSDictionary *dict = @{@"image":@"img_defaulthead_nor",
                               @"label":[NSString stringWithFormat:@"%d",i],
                               };
        [arr addObject:dict];
    }
    inputToolbar.typeDatas = [arr copy];
    inputToolbar.textViewMaxLine = 4;
    [self.view addSubview:inputToolbar];
}

#pragma MTInputToolbarDelegate

- (void)inputToolbar:(MTInputToolbar *)inputToolbar sendContent:(NSAttributedString *)sendContent
{
    NSLog(@"%@",sendContent);
}

- (void)inputToolbar:(MTInputToolbar *)inputToolbar sendRecordData:(NSData *)Data
{
    NSLog(@"%@",Data);
}

- (void)inputToolbar:(MTInputToolbar *)inputToolbar indexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@",indexPath);

}

@end
