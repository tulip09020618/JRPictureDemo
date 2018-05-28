//
//  JRPictureModel.h
//  JRPictureDemo
//
//  Created by hqtech on 2018/5/27.
//  Copyright © 2018年 tulip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JRPictureModel : NSObject

// title
@property (nonatomic, copy) NSString *title;
// description
@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *imgUrl;

/**
 原始图片
 */
@property (nonatomic, strong) UIImage *originalImg;

/**
 缩略图
 */
@property (nonatomic, strong) UIImage *thumbImg;

@end
