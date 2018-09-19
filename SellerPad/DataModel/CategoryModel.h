//
//  CategoryModel.h
//  SellerPad
//
//  Created by zhuyuming-MAC on 2018/5/7.
//  Copyright © 2018年 zhuyuming-MAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
@interface CategoryModel : NSObject
@property(nonatomic,assign) long Id;
@property(nonatomic,strong) NSString<Optional> *MerchantId;
@property(nonatomic,strong) NSString<Optional> *StepId;
@property(nonatomic,strong) NSString<Optional> *Type;
@property(nonatomic,strong) NSString<Optional> *Name;
@property(nonatomic,strong) NSString<Optional> *Image1;
@property(nonatomic,strong) NSString<Optional> *Image2;
@property(nonatomic,strong) NSString<Optional> *EName;
@property(nonatomic,strong) NSString<Optional> *MerchantName;
@end

@protocol CategoryModel <NSObject>

@end
