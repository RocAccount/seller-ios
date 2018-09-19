//
//  PhotosVC.h
//  SellerPad
//
//  Created by zhuyuming-MAC on 2018/9/3.
//  Copyright © 2018年 zhuyuming-MAC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContentModel.h"

@protocol PhotosVCDelegate <NSObject>

@end

@interface PhotosVC : UIViewController
@property(nonatomic, weak) id<PhotosVCDelegate>delegate;
@property (strong,nonatomic) ContentModel * contentItem;
@end


