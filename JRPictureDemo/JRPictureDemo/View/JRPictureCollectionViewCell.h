//
//  JRPictureCollectionViewCell.h
//  JRPictureDemo
//
//  Created by hqtech on 2018/5/27.
//  Copyright © 2018年 tulip. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JRPictureCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@end
