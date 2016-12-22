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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    MTInputToolbar *bar = [[MTInputToolbar alloc] initWithFrame:CGRectMake(0,MTScreenH - 50 , MTScreenW, 50)];
    bar.textViewMaxLine = 4;
    [self.view addSubview:bar];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
