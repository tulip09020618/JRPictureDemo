//
//  JRXMLDataParser.h
//  JRPictureDemo
//
//  Created by hqtech on 2018/5/27.
//  Copyright © 2018年 tulip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRPictureModel.h"

@interface JRXMLDataParser : NSObject

@property (nonatomic, strong) void (^ parseComplete) (NSArray *pictureModels);

// 开始解析数据
- (void)startParse;

@end
