//
//  JRBigPictureViewController.h
//  JRPictureDemo
//
//  Created by hqtech on 2018/5/28.
//  Copyright © 2018年 tulip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JRPictureAnimator.h"

@interface JRBigPictureViewController : UIViewController<JRPictureAnimatorDismissDelegate>

@property (nonatomic, strong) UIImage *image;

@end
