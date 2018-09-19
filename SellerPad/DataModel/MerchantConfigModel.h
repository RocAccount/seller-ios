//
//  MerchantConfigModel.h
//  SellerPad
//
//  Created by zhuyuming-MAC on 2018/5/7.
//  Copyright © 2018年 zhuyuming-MAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface MerchantConfigItem : JSONModel
@property(nonatomic,assign) long Id;
@property(nonatomic,strong) NSString<Optional>* ConfigId;
@property(nonatomic,strong) NSString<Optional>* ItemId;
@property(nonatomic,strong) NSString<Optional>* Hide;
@property(nonatomic,strong) NSString<Optional>* StepId;
@end

@protocol MerchantConfigItem <NSObject>
@end

@interface MerchantConfigModel : JSONModel
@property(nonatomic,assign) long Id;
@property(nonatomic,strong) NSString<Optional>* StepId;
@property(nonatomic,strong) NSString<Optional>* Hide;
@property(nonatomic,strong) NSString<Optional>* MerchantId;
@property(nonatomic,strong) NSArray<MerchantConfigItem,Optional>* Items;
@end

@protocol MerchantConfigModel <NSObject>

@end
