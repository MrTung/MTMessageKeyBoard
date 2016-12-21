//
//  MTInputToolbar.m
//  MTMessageKeyBoardDemo
//
//  Created by 董徐维 on 2016/12/21.
//  Copyright © 2016年 Mr.Tung. All rights reserved.
//

// 颜色
#define MTColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]


#define MTScreenW [UIScreen mainScreen].bounds.size.width

#define MTScreenH [UIScreen mainScreen].bounds.size.height

#define kCustomKeyboardHeight 200

#import "MTInputToolbar.h"

#import "UIView+Extension.h"

#import "MTEmojiView.h"
#import "MTMoreView.h"

@interface MTInputToolbar()<UITextViewDelegate,EmojiViewDelegate>
{
    
}

/***键盘高度***/
@property (nonatomic, assign)CGFloat keyboardHeight;

/***文本输入框高度***/
@property (nonatomic, assign)CGFloat textInputHeight;

/***文本输入框最高高度***/
@property (nonatomic, assign)NSInteger textInputMaxHeight;

/***当前键盘是否可见*/
@property (nonatomic,assign)BOOL keyboardIsVisiable;

/******/
@property (nonatomic, assign)BOOL showKeyboardButton;

/***语音按钮***/
@property (nonatomic,strong)UIButton *voiceButton;

/***文本输入框***/
@property (nonatomic,strong)UITextView *textInput;

/***表情按钮***/
@property (nonatomic,strong)UIButton *emojiButton;

/***更多按钮***/
@property (nonatomic,strong)UIButton *moreButton;


@property (nonatomic,strong)MTEmojiView *emojiView;

@property (nonatomic,strong)MTMoreView *moreView;

@property (nonatomic,strong)UIButton *voiceView;


@end
@implementation MTInputToolbar


- (void)setTextViewMaxLine:(NSInteger)textViewMaxLine
{
    _textViewMaxLine = textViewMaxLine;
    _textInputMaxHeight = ceil(self.textInput.font.lineHeight * (textViewMaxLine - 1) +
                               self.textInput.textContainerInset.top + self.textInput.textContainerInset.bottom);
}

- (MTMoreView *)moreView
{
    if (!_moreView) {
        self.moreView = [[MTMoreView alloc] initWithFrame:CGRectMake(0, 0, self.width, kCustomKeyboardHeight)];
        _keyboardHeight = kCustomKeyboardHeight;
    }
    return _moreView;
}

- (MTEmojiView *)emojiView
{
    if (!_emojiView) {
        self.emojiView = [[MTEmojiView alloc] initWithFrame:CGRectMake(0, 0, self.width, kCustomKeyboardHeight)];
        self.emojiView.delegate = self;
        _keyboardHeight = kCustomKeyboardHeight;
    }
    return _emojiView;
}

- (UIButton *)voiceView
{
    if (!_voiceView) {
        self.voiceView = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.voiceButton.frame) + 5, 7, MTScreenW - 115, 32)];
        self.voiceView.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [self.voiceView setTitle:@"按住说话" forState:UIControlStateNormal];
        [self.voiceView setTitle:@"松开结束" forState:UIControlStateFocused];
        [self.voiceView setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.voiceView setTitleColor:[UIColor darkGrayColor] forState:UIControlStateFocused];
        
        self.voiceView.backgroundColor = MTColor(243, 243, 243);
        self.voiceView.layer.borderColor = MTColor(210, 210, 210).CGColor;
        self.voiceView.layer.borderWidth = 0.5;
        self.voiceView.layer.cornerRadius = 3;
        _keyboardHeight = 0;
    }
    return _voiceView;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self endEditing:YES];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initView];
        
        [self setupSubviews];
        
        [self addEventListening];
    }
    return self;
}

-(void)initView
{
    self.backgroundColor = MTColor(243, 243, 243);
    
    if (!self.textViewMaxLine || self.textViewMaxLine == 0) {
        self.textViewMaxLine = 4;
    }
}

-(void)addEventListening
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardHeight = keyboardFrame.size.height;
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:7];
    self.y = keyboardFrame.origin.y - self.height;
    [UIView commitAnimations];
    //    _inputToolbarFrameChange(self.height,self.y);
    self.keyboardIsVisiable = YES;
}

- (void)keyboardWillHidden:(NSNotification *)notification
{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        self.y = keyboardFrame.origin.y - self.height;
    }];
    //    _inputToolbarFrameChange(self.height,self.y);
    //    //NSLog(@"%lf  %lf",self.height,self.y);
    self.keyboardIsVisiable = NO;
    //    [self setShowKeyboardButton:NO];
}

/**
 初始化UI
 */
-(void)setupSubviews
{
    self.voiceButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 9, 30, 30)];
    [self.voiceButton setImage:[UIImage imageNamed:@"liaotian_ic_yuyin_nor"] forState:UIControlStateNormal];
    [self.voiceButton setImage:[UIImage imageNamed:@"liaotian_ic_press"] forState:UIControlStateHighlighted];
    [self.voiceButton addTarget:self action:@selector(voiceButtonclickHandler) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.voiceButton];
    
    self.textInput = [[UITextView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.voiceButton.frame) + 5, 7, MTScreenW - 115, 32)];
    self.textInput.font = [UIFont systemFontOfSize:18];
    
    self.textInput.userInteractionEnabled = YES;
    //单击手势
    UITapGestureRecognizer *singleGestur = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleClick)];
    singleGestur.numberOfTouchesRequired = 1;
    singleGestur.numberOfTapsRequired = 1;
    [self.textInput addGestureRecognizer:singleGestur];
    
    self.textInput.layer.cornerRadius = 3;
    self.textInput.layer.borderColor = MTColor(210, 210, 210).CGColor;
    self.textInput.layer.borderWidth = 0.5;
    self.textInput.layer.masksToBounds = YES;
    self.textInput.returnKeyType = UIReturnKeySend;
    self.textInput.enablesReturnKeyAutomatically = YES;
    self.textInput.delegate = self;
    [self addSubview:self.textInput];
    
    self.emojiButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.textInput.frame) + 5, 9, 30, 30)];
    [self.emojiButton setImage:[UIImage imageNamed:@"liaotian_ic_biaoqing_nor"] forState:UIControlStateNormal];
    [self.emojiButton setImage:[UIImage imageNamed:@"liaotian_ic_biaoqing_press"] forState:UIControlStateHighlighted];
    [self.emojiButton addTarget:self action:@selector(emojiButtonclickHandler) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.emojiButton];
    
    self.moreButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.emojiButton.frame) + 5, 9, 30, 30)];
    [self.moreButton setImage:[UIImage imageNamed:@"liaotian_ic_gengduo_nor"] forState:UIControlStateNormal];
    [self.moreButton setImage:[UIImage imageNamed:@"liaotian_ic_gengduo_press"] forState:UIControlStateHighlighted];
    [self.moreButton addTarget:self action:@selector(moreButtonclickHandler) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.moreButton];
}

#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    _textInputHeight = ceilf([self.textInput sizeThatFits:CGSizeMake(self.textInput.width, MAXFLOAT)].height);
    self.textInput.scrollEnabled = _textInputHeight > _textInputMaxHeight && _textInputMaxHeight > 0;
    if (self.textInput.scrollEnabled) {
        self.textInput.height = 5 + _textInputMaxHeight;
        self.y = MTScreenH - _keyboardHeight - _textInputMaxHeight - 5 - 8;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:7];
        self.height = _textInputMaxHeight + 15;
        [UIView commitAnimations];
    } else {
        self.textInput.height = _textInputHeight;
        self.y = MTScreenH - _keyboardHeight - _textInputHeight - 5 - 8;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:7];
        self.height = _textInputHeight + 15;
        [UIView commitAnimations];
    }
    self.voiceButton.y = self.emojiButton.y = self.moreButton.y = self.height - self.voiceButton.height - 12;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
       return YES;
}


#pragma mark clickHandler

-(void)voiceButtonclickHandler
{
    //    [self.textInput removeFromSuperview];
    //    [self addSubview:self.voiceView];
    [self switchToKeyboard:[UIView new]];
}

-(void)emojiButtonclickHandler
{
    [self switchToKeyboard:self.emojiView];
}

-(void)moreButtonclickHandler
{
    [self switchToKeyboard:self.moreView];
}

-(void)singleClick
{
//    self.textInput.inputView = nil;
//    [self.textInput endEditing:YES];
//    [self.textInput becomeFirstResponder];
}

/**
 切换inputView
 @param keyboard inputView
 */
- (void)switchToKeyboard:(UIView *)keyboard
{
    if (self.textInput.inputView == nil || !self.keyboardIsVisiable) {
        self.textInput.inputView = keyboard;
    } else {
        //优先弹出非键盘keyboard
        if (self.textInput.inputView != keyboard) {
            self.textInput.inputView = keyboard;
        } else {
            self.textInput.inputView = nil;
        }
        self.showKeyboardButton = NO;
    }
    [self.textInput endEditing:YES];
    [self.textInput becomeFirstResponder];
}

#pragma mark EmojiViewDelegate

- (void)emojiView:(MTEmojiView *)emojiView emojiText:(NSObject *)text
{
    if ([text  isEqual: @"DeleteButtonId"]) {
        [self.textInput deleteBackward];
        return;
    }
    if (![text isKindOfClass:[UIImage class]]) {
        [self.textInput replaceRange:self.textInput.selectedTextRange withText:(NSString *)text];
    } else {
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil] ;
        textAttachment.image = (UIImage *)text;
        textAttachment.bounds = CGRectMake(0, - 5, self.textInput.font.lineHeight + 2, self.textInput.font.lineHeight + 2);
        NSAttributedString *imageText = [NSAttributedString attributedStringWithAttachment:textAttachment];
        
        NSMutableAttributedString *strM = [[NSMutableAttributedString alloc] initWithAttributedString:self.textInput.attributedText];
        [strM replaceCharactersInRange:self.textInput.selectedRange withAttributedString:imageText];
        [strM addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(self.textInput.selectedRange.location, 1)];
        self.textInput.attributedText = strM;
        self.textInput.selectedRange = NSMakeRange(self.textInput.selectedRange.location + 1,0);
        [self.textInput.delegate textViewDidChange:self.textInput];
    }
}

- (void)emojiView:(MTEmojiView *)emojiView sendButtonClick:(UIButton *)sender
{
    NSLog(@"send。。。。。。");
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
