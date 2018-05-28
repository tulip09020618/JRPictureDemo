//
//  JRLaunchScreenView.m
//  JRPictureDemo
//
//  Created by hqtech on 2018/5/28.
//  Copyright © 2018年 tulip. All rights reserved.
//

#import "JRLaunchScreenView.h"
#import <WebKit/WebKit.h>

@interface JRLaunchScreenView ()

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation JRLaunchScreenView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    NSString *launchImgPath = [[NSBundle mainBundle] pathForResource:@"launchImg" ofType:@"svg"];
    NSData *launchData = [NSData dataWithContentsOfFile:launchImgPath];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSURL *baseUrl = [[NSURL alloc] initFileURLWithPath:resourcePath isDirectory:true];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 100, [UIScreen mainScreen].bounds.size.width, 50)];
    [self.webView loadData:launchData MIMEType:@"image/svg+xml" characterEncodingName:@"UTF-8" baseURL:baseUrl];
    [self addSubview:self.webView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 3秒后异步执行这里的代码...
        [self removeFromSuperview];
        
    });
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
