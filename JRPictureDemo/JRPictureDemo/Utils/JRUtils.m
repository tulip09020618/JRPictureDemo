//
//  JRUtils.m
//  JRPictureDemo
//
//  Created by hqtech on 2018/5/28.
//  Copyright © 2018年 tulip. All rights reserved.
//

#import "JRUtils.h"

@implementation JRUtils

#pragma mark 获取高度
+ (CGFloat)getHeight:(NSString *)string fontSize:(CGFloat)fontSize width:(CGFloat)width {
    
    NSString *str = string;
    
    if (!str) {
        return 20;
    }
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:str];
    
    //字体
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    [attributeString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, str.length)];
    
    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGRect rect = [attributeString boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:options context:nil];
    
    return rect.size.height;
}

@end
