//
//  ImageCell.m
//  SellerPad
//
//  Created by zhuyuming-MAC on 2018/9/13.
//  Copyright © 2018年 zhuyuming-MAC. All rights reserved.
//

#import "ImageCell.h"
#import "Masonry.h"
@implementation ImageCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        [self initialize];
    }
    return self;
}


- (void)initialize {
    self.layer.doubleSided = NO;
    
    self.image = [[UIImageView alloc] init];
    self.image.backgroundColor = [UIColor clearColor];
    self.image.contentMode = UIViewContentModeScaleAspectFit;
    self.image.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageBtn = [[UIButton alloc] init];
    self.imageBtn.contentMode = UIViewContentModeScaleAspectFit;
    self.imageBtn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.imageBtn setBounds:CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height)];
//    [self.image.layer setBorderWidth:1.0];
//    [self.image.layer setBorderColor:[UIColor blackColor].CGColor];
//    [self.imageBtn.layer setBorderWidth:1.0];
//    [self.imageBtn.layer setBorderColor:[UIColor redColor].CGColor];
    [self.contentView addSubview:self.image];
    [self.contentView addSubview:self.imageBtn];
 
    
    [_image mas_makeConstraints:^(MASConstraintMaker *make) {
       // make.top.and.bottom.mas_equalTo(-5);
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(5);
        make.right.mas_equalTo(-5);
       // make.size.height.mas_equalTo();
        //make.size.width.mas_equalTo(([[UIScreen mainScreen] bounds].size.width-10.0*4)/2).priority(999);
        //make.left.right.equalTo(self.contentView).offset(10);
     
       
    }];
    
    [_imageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.mas_equalTo(0);
        make.left.mas_equalTo(5);
        make.right.mas_equalTo(-5);
        // make.size.height.mas_equalTo();
        //make.size.width.mas_equalTo(([[UIScreen mainScreen] bounds].size.width-10.0*4)/2).priority(999);
        //make.left.right.equalTo(self.contentView).offset(10);
        
        
    }];
    

}


@end
