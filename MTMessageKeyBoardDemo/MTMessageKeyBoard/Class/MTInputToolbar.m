//
//  MTInputToolbar.m
//  MTMessageKeyBoardDemo
//
//  Created by 董徐维 on 2016/12/21.
//  Copyright © 2016年 Mr.Tung. All rights reserved.
//


typedef enum {
    InputToolBarStatusTypeDefault,
    InputToolBarStatusTypeVoice,
    InputToolBarStatusTypeEmoji,
    InputToolBarStatusTypeMore,
} InputToolBarStatusType;

#define kCustomKeyboardHeight 200

//按钮距离下边距离
#define kButtonMargin 10
//按钮宽高
#define kButtonWH 30
//输入框高度
#define kInputHeight 37

#import "MTInputToolbar.h"

#import "UIView+Extension.h"
#import "MBProgressHUD.h"
#import "MTRecordHelper.h"

#import "MTEmojiView.h"
#import "MTMoreView.h"

@interface MTInputToolbar()<UITextViewDelegate,EmojiViewDelegate>
{
    //录音开始的时间
    CFAbsoluteTime recordStarttime;
    
    MBProgressHUD *hud;
    
    NSAttributedString *contentStr;
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

@property (nonatomic,strong)NSMutableArray *buttonArr;


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
        _moreView = [[MTMoreView alloc] initWithFrame:CGRectMake(0, 0, self.width, kCustomKeyboardHeight)];
        _keyboardHeight = kCustomKeyboardHeight;
        
        __weak __typeof(id)weakdelegate = _delegate;
        __weak __typeof(self)weakSelf = self;
        
        _moreView.didSelectItemAtIndexPath = ^(NSIndexPath *indexPath){
            if ([weakdelegate respondsToSelector:@selector(inputToolbar:indexPath:)]) {
                [weakdelegate inputToolbar:weakSelf indexPath:indexPath];
            }
        };
    }
    return _moreView;
}

- (MTEmojiView *)emojiView
{
    if (!_emojiView) {
        _emojiView = [[MTEmojiView alloc] initWithFrame:CGRectMake(0, 0, self.width, kCustomKeyboardHeight)];
        _emojiView.delegate = self;
        _keyboardHeight = kCustomKeyboardHeight;
    }
    return _emojiView;
}

- (UIButton *)voiceView
{
    if (!_voiceView) {
        _voiceView = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.voiceButton.frame) + 5, 7, MTScreenW - 115, kInputHeight)];
        _voiceView.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_voiceView setTitle:@"按住 说话" forState:UIControlStateNormal];
        [_voiceView setTitle:@"松开 发送" forState:UIControlStateHighlighted];
        [_voiceView setBackgroundImage:[[UIImage imageNamed:@"chatBar_recordSelectedBg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateHighlighted];
        [_voiceView addTarget:self action:@selector(voiceButtonTouchDown) forControlEvents:UIControlEventTouchDown];
        [_voiceView addTarget:self action:@selector(voiceButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
        [_voiceView addTarget:self action:@selector(voiceButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [_voiceView addTarget:self action:@selector(voiceDragOutside) forControlEvents:UIControlEventTouchDragExit];
        [_voiceView addTarget:self action:@selector(voiceDragInside) forControlEvents:UIControlEventTouchDragEnter];
        
        [_voiceView setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_voiceView setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        
        _voiceView.backgroundColor = MTColor(243, 243, 243);
        _voiceView.layer.borderColor = MTColor(210, 210, 210).CGColor;
        _voiceView.layer.borderWidth = 0.5;
        _voiceView.layer.cornerRadius = 3;
        [self addSubview:_voiceView];
        if (self.voiceButton.selected)
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
    _buttonArr = [[NSMutableArray alloc] init];
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

/**
 初始化UI
 */
-(void)setupSubviews
{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 0.5)];
    line.backgroundColor = MTColor(220, 220, 220);
    [self addSubview:line];
    
    self.voiceButton = [[UIButton alloc] initWithFrame:CGRectMake(5, self.height - kButtonWH - kButtonMargin, kButtonWH, kButtonWH)];
    [self.voiceButton setImage:[UIImage imageNamed:@"liaotian_ic_yuyin_nor"] forState:UIControlStateNormal];
    [self.voiceButton setImage:[UIImage imageNamed:@"liaotian_ic_press"] forState:UIControlStateHighlighted];
    [self.voiceButton setImage:[UIImage imageNamed:@"liaotian_ic_jianpan_nor"] forState:UIControlStateSelected];
    
    [self.voiceButton addTarget:self action:@selector(voiceButtonclickHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.voiceButton];
    [_buttonArr addObject:self.voiceButton];
    
    self.textInput = [[UITextView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.voiceButton.frame) + 5, (self.height - kInputHeight)/2, MTScreenW - 115, 37)];
    self.textInput.font = [UIFont systemFontOfSize:17];
    self.textInput.layer.cornerRadius = 3;
    self.textInput.layer.borderColor = MTColor(210, 210, 210).CGColor;
    self.textInput.layer.borderWidth = 0.5;
    self.textInput.layer.masksToBounds = YES;
    self.textInput.returnKeyType = UIReturnKeySend;
    self.textInput.enablesReturnKeyAutomatically = YES;
    self.textInput.delegate = self;
    [self addSubview:self.textInput];
    
    self.emojiButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.textInput.frame) + 5, self.height - kButtonWH - kButtonMargin, kButtonWH, kButtonWH)];
    [self.emojiButton setImage:[UIImage imageNamed:@"liaotian_ic_biaoqing_nor"] forState:UIControlStateNormal];
    [self.emojiButton setImage:[UIImage imageNamed:@"liaotian_ic_biaoqing_press"] forState:UIControlStateHighlighted];
    [self.emojiButton setImage:[UIImage imageNamed:@"liaotian_ic_jianpan_nor"] forState:UIControlStateSelected];
    [self.emojiButton addTarget:self action:@selector(emojiButtonclickHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.emojiButton];
    [_buttonArr addObject:self.emojiButton];
    
    self.moreButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.emojiButton.frame) + 5, self.height - kButtonWH - kButtonMargin, kButtonWH, kButtonWH)];
    [self.moreButton setImage:[UIImage imageNamed:@"liaotian_ic_gengduo_nor"] forState:UIControlStateNormal];
    [self.moreButton setImage:[UIImage imageNamed:@"liaotian_ic_gengduo_press"] forState:UIControlStateHighlighted];
    [self.moreButton setImage:[UIImage imageNamed:@"liaotian_ic_jianpan_nor"] forState:UIControlStateSelected];
    [self.moreButton addTarget:self action:@selector(moreButtonclickHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.moreButton];
    [_buttonArr addObject:self.moreButton];
    
}

#pragma mark keyboardnotification

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

#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    if (!self.voiceButton.selected) {
        // 保存文本内容
        contentStr = textView.attributedText;
    }
    
    _textInputHeight = ceilf([self.textInput sizeThatFits:CGSizeMake(self.textInput.width, MAXFLOAT)].height);
    self.textInput.scrollEnabled = _textInputHeight > _textInputMaxHeight && _textInputMaxHeight > 0;
    if (self.textInput.scrollEnabled) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:7];
        self.textInput.height = 5 + _textInputMaxHeight;
        self.y = MTScreenH - _keyboardHeight - _textInputMaxHeight - 5 - 8;
        self.height = _textInputMaxHeight + 15;
        [UIView commitAnimations];
    } else {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:7];
        self.textInput.height = _textInputHeight;
        self.y = MTScreenH - _keyboardHeight - _textInputHeight - 5 - 8;
        self.height = _textInputHeight + 15;
        [UIView commitAnimations];
    }
    self.voiceButton.y = self.emojiButton.y = self.moreButton.y = self.height - self.voiceButton.height - kButtonMargin;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]){
        
        if ([_delegate respondsToSelector:@selector(inputToolbar:sendContent:)]) {
            [_delegate inputToolbar:self sendContent:self.textInput.attributedText];
        }
        
        self.textInput.attributedText = nil;
        [self.textInput.delegate textViewDidChange:self.textInput];
        return NO;
    }
    
    return YES;
}

#pragma mark clickHandler

-(void)voiceButtonclickHandler:(UIButton*)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    if (button.selected) {
        //置空文本框
        self.textInput.attributedText = nil;
        [self.textInput.delegate textViewDidChange:self.textInput];
        
        [self switchToKeyboard:[UIView new]];
    }
    else{
        self.textInput.inputView = nil;
        [self.textInput endEditing:YES];
        [self.textInput becomeFirstResponder];
        
        //恢复文本框
        self.textInput.attributedText = contentStr;
        [self.textInput.delegate textViewDidChange:self.textInput];
    }
    
    [self refleshButtonStatus:sender];
}

-(void)emojiButtonclickHandler:(UIButton*)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    [self switchToKeyboard:self.emojiView];
    [self refleshButtonStatus:sender];
    
    if (contentStr) {
        self.textInput.attributedText = contentStr;
        [self.textInput.delegate textViewDidChange:self.textInput];
    }
}

-(void)moreButtonclickHandler:(UIButton*)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    [self switchToKeyboard:self.moreView];
    [self refleshButtonStatus:sender];
    
    if (contentStr) {
        self.textInput.attributedText = contentStr;
        [self.textInput.delegate textViewDidChange:self.textInput];
    }
}

-(void)refleshButtonStatus:(UIButton*)sender
{
    for (UIButton *btn in self.buttonArr) {
        if (btn != sender) {
            btn.selected = NO;
        }
    }
    
    if (self.voiceButton.selected) {
        [self.voiceView setHidden:NO];
        [self.textInput setHidden:YES];
    }
    else{
        [self.voiceView setHidden:YES];
        [self.textInput setHidden:NO];
    }
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

#pragma mark 语音输入模块

- (void)voiceButtonTouchDown
{
    recordStarttime = CFAbsoluteTimeGetCurrent();
    
    hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    UIImage *image = [UIImage imageNamed:@"mic_0"];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.square = YES;
    hud.contentColor = [UIColor whiteColor];
    
    hud.bezelView.color = [UIColor colorWithRed:116/255 green:116/255 blue:116/255 alpha:0.66];
    hud.bezelView.layer.cornerRadius = 8;
    hud.label.text = @"手指上滑,取消发送";
    //录音
    [MTRecordHelper shareRecordHelper].recordEndBlock = ^(NSData *data){
        NSLog(@"录音完成");
        
        if ([_delegate respondsToSelector:@selector(inputToolbar:sendRecordData:)]) {
            [_delegate inputToolbar:self sendRecordData:data];
        }
    };
    
    [MTRecordHelper shareRecordHelper].recordingBlock = ^(float recordTime,float volume){
        
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"mic_%.0f.png",volume*10 > 5 ? 5 : volume*10]];
        hud.customView = [[UIImageView alloc] initWithImage:image];
        
        NSLog(@"正在录音");
    };
    
    [[MTRecordHelper shareRecordHelper] startRecord];
}

- (void)voiceButtonTouchUpOutside
{
    [hud hideAnimated:YES];
}

- (void)voiceButtonTouchUpInside
{
    CFAbsoluteTime end  = CFAbsoluteTimeGetCurrent();
    NSString *str = [NSString stringWithFormat:@"%0.3f", (end - recordStarttime)*1000];
    if ([str floatValue] < 1000)
    {
        NSLog(@"录音时间太短");
        hud.label.text = @"说话时间太短";
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"worning.png"]];
        [hud hideAnimated:YES afterDelay:2.0f];
    }
    else
    {
        [hud hideAnimated:YES afterDelay:0.3f];
    }
    [[MTRecordHelper shareRecordHelper] stopRecord];
}

- (void)voiceDragOutside
{
    hud.label.backgroundColor = MTColor(158, 56, 54);
    hud.label.layer.cornerRadius = 4;
    hud.label.layer.masksToBounds = YES;
    hud.label.text = @"松开手指,取消发送";
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cancel.png"]];
    [[MTRecordHelper shareRecordHelper] stopRecord];
}

- (void)voiceDragInside
{
    hud.label.backgroundColor = [UIColor clearColor];
    hud.label.text = @"手指上滑,取消发送";
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mic_0.png"]];
    [[MTRecordHelper shareRecordHelper] stopRecord];
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
    
    if ([_delegate respondsToSelector:@selector(inputToolbar:sendContent:)]) {
        [_delegate inputToolbar:self sendContent:self.textInput.attributedText];
    }
    
    self.textInput.attributedText = nil;
    [self.textInput.delegate textViewDidChange:self.textInput];
}

#pragma mark

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
