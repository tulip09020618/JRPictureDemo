//
//  JRPictureModel.m
//  JRPictureDemo
//
//  Created by hqtech on 2018/5/27.
//  Copyright © 2018年 tulip. All rights reserved.
//

#import "JRPictureModel.h"

@implementation JRPictureModel

- (NSString *)title {
    if (_title == nil) {
        _title = @"";
    }
    return _title;
}

- (NSString *)content {
    if (_content == nil) {
        _content = @"";
    }
    return _content;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"title:%@, content:%@, imgUrl:%@", self.title, self.content, self.imgUrl];
}

@end
