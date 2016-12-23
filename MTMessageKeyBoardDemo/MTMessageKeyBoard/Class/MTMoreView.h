//
//  MTMoreView.h
//  MTMessageKeyBoardDemo
//
//  Created by 董徐维 on 2016/12/21.
//  Copyright © 2016年 Mr.Tung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTMoreView : UIView

@property (nonatomic, copy) void (^didSelectItemAtIndexPath)(NSIndexPath *indexPath);

@end
