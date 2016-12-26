//
//  MTCollectionViewHorizontalLayout.h
//  MTMessageKeyBoardDemo
//
//  Created by 董徐维 on 2016/12/25.
//  Copyright © 2016年 Mr.Tung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTCollectionViewHorizontalLayout : UICollectionViewFlowLayout
@property (nonatomic) NSUInteger itemCountPerRow;
@property (nonatomic) NSUInteger rowCount;
@property (strong, nonatomic) NSMutableArray *allAttributes;

@end
