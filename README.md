# MTMessageKeyBoard
MTMessageKeyBoard

## Requirements
* iOS 7.0 or later
* Xcode 7.0 or later

## Architecture
### Main
- `MTInputToolbar`
- `EmojiDataHelper`
- `MTRecordHelper`
- `MTEmojiView`
- `MTMoreView`

### Category
- `UIView+Extension`

MTMessageKeyBoard简介：
app中需要用到聊天、咨询、发送文本信息等内容的时候可能需要用到的插件库。

###用法：

## <a id="Details"></a>Details (See the example program PYSearchExample for details)
```objc
#import "MTInputToolbar.h"

@interface ViewController ()<MTInputToolbarDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MTInputToolbar *inputToolbar = [[MTInputToolbar alloc] initWithFrame:CGRectMake(0,MTScreenH - 50 , MTScreenW, 50)];
    inputToolbar.delegate = self;
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


```

