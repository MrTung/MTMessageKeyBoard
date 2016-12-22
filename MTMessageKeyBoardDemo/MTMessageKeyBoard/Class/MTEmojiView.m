//
//  MTEmojiView.m
//  MTMessageKeyBoardDemo
//
//  Created by 董徐维 on 2016/12/21.
//  Copyright © 2016年 Mr.Tung. All rights reserved.
//


#define MTScreenW [UIScreen mainScreen].bounds.size.width

#define MTScreenH [UIScreen mainScreen].bounds.size.height

#define kFootViewButtonWidth self.width/8

#define EMOJI_CODE_TO_SYMBOL(x) ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24);

#import "MTEmojiView.h"
#import "EmojiCollectionViewCell.h"
#import "UIView+Extension.h"
#import "EmojiDataHelper.h"

@interface MTEmojiView ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,strong)UIView *emojiFooterView;

@property (nonatomic,strong)UIScrollView *emojiFooterScrollView;

@property (nonatomic,strong)UIPageControl *pageControl;

@property (nonatomic,strong)UIButton *sendButton;

@property (nonatomic,strong)UIButton *emojiTypeButton1;

@property (nonatomic,strong)UIButton *emojiTypeButton2;

@property (nonatomic,strong)NSMutableArray *defaultEmoticons;

/**表情图数据源**/
@property (nonatomic,strong)NSArray *emojiImageDataProvider;

@property (nonatomic,strong)UICollectionView *collectionView;

@property (nonatomic,strong)UICollectionViewFlowLayout *layout;

@end
@implementation MTEmojiView

-(UICollectionViewFlowLayout*)layout
{
    if (!_layout)
        _layout =[[UICollectionViewFlowLayout alloc]init];

    CGFloat W = (self.collectionView.bounds.size.width) / 7;
    CGFloat H = (self.collectionView.bounds.size.height) / 3;
    
    _layout.itemSize = CGSizeMake(W, H);
    _layout.minimumLineSpacing = 0;
    _layout.minimumInteritemSpacing = 0;
    _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _layout.collectionView.bounces = YES;
    
    CGFloat Y = (self.collectionView.bounds.size.height - 3 * H);
    _layout.collectionView.contentInset = UIEdgeInsetsMake(Y, 0, 0, 0);
    return _layout;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _defaultEmoticons = [NSMutableArray array];
        
        _emojiImageDataProvider = [NSMutableArray array];
        
        //初始化datahelper 并创建数据
        [[EmojiDataHelper shareEmojiData] initEmojiData];
        _emojiImageDataProvider = [EmojiDataHelper shareEmojiData].images;
        
        //解决编码问题
        for (int i=0x1F600; i<=0x1F64F; i++) {
            if (i < 0x1F641 || i > 0x1F640) {
                int sym = EMOJI_CODE_TO_SYMBOL(i);
                NSString *emoT = [[NSString alloc] initWithBytes:&sym length:sizeof(sym) encoding:NSUTF8StringEncoding];
                [_defaultEmoticons addObject:emoT];
            }
        }
        
        [_defaultEmoticons addObjectsFromArray:[EmojiDataHelper shareEmojiData].images];
        
        for (NSInteger i = 0;i < _defaultEmoticons.count;i ++) {
            if (i == 20 || i == 41 || i == 62 || i == 83 || i == 104 || i == 125 || i == 146 || i == 167) {
                [_defaultEmoticons insertObject:@"DeleteButtonId" atIndex:i];
            }
        }
        
        if (self.defaultEmoticons.count % 21 != 0) {
            for (NSInteger i = self.defaultEmoticons.count; i < self.defaultEmoticons.count + 21; i ++) {
                [self.defaultEmoticons addObject:@""];
                if (self.defaultEmoticons.count % 21 == 0) {
                    break;
                }
            }
        }
        [self.defaultEmoticons replaceObjectAtIndex:self.defaultEmoticons.count - 1 withObject:@"DeleteButtonId"];
        self.backgroundColor = [UIColor colorWithRed:243 / 255.0 green:243 / 255.0 blue:243 / 255.0 alpha:1];
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews
{
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MTScreenW, 0.5)];
    line1.backgroundColor =  [UIColor colorWithRed:220 / 255.0 green:220 / 255.0 blue:220 / 255.0 alpha:1];
    [self addSubview:line1];
    
    self.emojiFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 160, MTScreenW, 40)];
    self.emojiFooterView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.emojiFooterView];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 160, MTScreenW, 0.5)];
    line.backgroundColor = [UIColor colorWithRed:220 / 255.0 green:220 / 255.0 blue:220 / 255.0 alpha:1];
    [self addSubview:line];
    
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(MTScreenW - kFootViewButtonWidth, 0, kFootViewButtonWidth, 40)];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    self.sendButton.backgroundColor = [UIColor blueColor];
    self.sendButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(senderButtonClickHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.emojiFooterView addSubview:self.sendButton];
    
    self.emojiFooterScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, MTScreenW - kFootViewButtonWidth - 1, self.emojiFooterView.height)];
    self.emojiFooterScrollView.showsHorizontalScrollIndicator = NO;
    self.emojiFooterScrollView.showsVerticalScrollIndicator = NO;
    self.emojiFooterScrollView.contentSize = CGSizeMake(MTScreenW - kFootViewButtonWidth, self.emojiFooterView.height);
    [self.emojiFooterView addSubview:self.emojiFooterScrollView];
    
    self.emojiTypeButton1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kFootViewButtonWidth, 40)];
    [self.emojiTypeButton1 setImage:[UIImage imageNamed:@"liaotian_ic_biaoqing_nor"] forState:UIControlStateNormal];
    [self.emojiTypeButton1 setImage:[UIImage imageNamed:@"liaotian_ic_biaoqing_press"] forState:UIControlStateSelected];
    [self.emojiTypeButton1 addTarget:self action:@selector(emojiButton1ClickHandler) forControlEvents:UIControlEventTouchUpInside];
    [self.emojiFooterScrollView addSubview:self.emojiTypeButton1];
    self.emojiTypeButton1.selected = YES;
    
    self.emojiTypeButton2 = [[UIButton alloc] initWithFrame:CGRectMake(kFootViewButtonWidth, 0, kFootViewButtonWidth, 40)];
    [self.emojiTypeButton2 setImage:[UIImage imageNamed:@"liaotian_ic_biaoqing_nor"] forState:UIControlStateNormal];
    [self.emojiTypeButton2 setImage:[UIImage imageNamed:@"liaotian_ic_biaoqing_press"] forState:UIControlStateSelected];
    [self.emojiTypeButton2 addTarget:self action:@selector(emojiButton2ClickHandler) forControlEvents:UIControlEventTouchUpInside];
    [self.emojiFooterScrollView addSubview:self.emojiTypeButton2];
    self.emojiTypeButton2.selected = NO;

    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(line1.frame) + 5, MTScreenW, 130) collectionViewLayout:self.layout];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.backgroundColor = [UIColor colorWithRed:243 / 255.0 green:243 / 255.0 blue:243 / 255.0 alpha:1];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self addSubview:self.collectionView];
    [self.collectionView registerClass:[EmojiCollectionViewCell class] forCellWithReuseIdentifier:@"MTUICollectionViewCell"];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((MTScreenW - self.pageControl.width)/2, 140, 0, 10)];
    self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.userInteractionEnabled = NO;
    
    self.pageControl.numberOfPages = (self.defaultEmoticons.count - self.emojiImageDataProvider.count) / 21;
    [self addSubview:self.pageControl];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.collectionView) {
        if (scrollView.contentOffset.x >= MTScreenW * ((self.defaultEmoticons.count - self.emojiImageDataProvider.count) / 21)) {
            self.pageControl.numberOfPages = self.emojiImageDataProvider.count % 21 == 0 ? self.emojiImageDataProvider.count % 21 : self.emojiImageDataProvider.count % 21 + 1 ;
            self.pageControl.currentPage = ((scrollView.contentOffset.x - MTScreenW * ((self.defaultEmoticons.count - self.emojiImageDataProvider.count) / 21)) / MTScreenW);
            self.emojiTypeButton1.selected = NO;
            self.emojiTypeButton2.selected = YES;
            
        } else {
            self.pageControl.numberOfPages = (self.defaultEmoticons.count - self.emojiImageDataProvider.count) / 21;
            self.pageControl.currentPage = (scrollView.contentOffset.x / MTScreenW);
            self.emojiTypeButton1.selected = YES;
            self.emojiTypeButton2.selected = NO;
        }
    }}

#pragma mark UICollectionViewDelegate

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.defaultEmoticons.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EmojiCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MTUICollectionViewCell" forIndexPath:indexPath];
    if ([self.defaultEmoticons[indexPath.row] isKindOfClass:[UIImage class]]) {
        cell.image = self.defaultEmoticons[indexPath.row];
    } else {
        cell.string = self.defaultEmoticons[indexPath.row];
    }
    return cell;
}

 -(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat W = (self.collectionView.bounds.size.width) / 7;
    CGFloat H = (self.collectionView.bounds.size.height) / 3;
    
    return CGSizeMake(W, H);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSObject *str = self.defaultEmoticons[indexPath.row];
    if (str) {
        if ([_delegate respondsToSelector:@selector(emojiView:emojiText:)]) {
            [_delegate emojiView:self emojiText:str];
        }
    }
}

#pragma mark clickHandler

- (void)emojiButton1ClickHandler
{
    self.emojiTypeButton1.selected = YES;
    self.emojiTypeButton2.selected = NO;
    [self.collectionView setContentOffset:CGPointMake(0, 0) animated:0];
    self.pageControl.numberOfPages = (self.defaultEmoticons.count - self.emojiImageDataProvider.count) / 21;
    self.pageControl.currentPage = (self.collectionView.contentOffset.x / MTScreenW);
}

- (void)emojiButton2ClickHandler
{
    self.emojiTypeButton1.selected = NO;
    self.emojiTypeButton2.selected = YES;
    [self.collectionView setContentOffset:CGPointMake(MTScreenW * 4, 0) animated:0];
    self.pageControl.numberOfPages = self.emojiImageDataProvider.count % 21 == 0 ? self.emojiImageDataProvider.count % 21 : self.emojiImageDataProvider.count % 21 + 1 ;
    self.pageControl.currentPage = ((self.collectionView.contentOffset.x - MTScreenW * ((self.defaultEmoticons.count - self.emojiImageDataProvider.count) / 21)) / MTScreenW);
}

- (void)senderButtonClickHandler:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(emojiView:sendButtonClick:)]) {
        [_delegate emojiView:self sendButtonClick:sender];
    }
}

@end
