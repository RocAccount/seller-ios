//
//  CustomerModel.h
//  SellerPad
//
//  Created by zhuyuming-MAC on 2018/5/21.
//  Copyright © 2018年 zhuyuming-MAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
@interface CustomerModel : JSONModel

@property(nonatomic,strong) NSString<Optional> *Id;
@property(nonatomic,strong) NSString<Optional> *Husband;
@property(nonatomic,strong) NSString<Optional> *Wife;
@property(nonatomic,strong) NSString<Optional> *Tel;
@property(nonatomic,strong) NSString<Optional> *Remark;
@property(nonatomic,strong) NSString<Optional> *WeddingDate;
@property(nonatomic,strong) NSString<Optional> *StoreId;
@property(nonatomic,strong) NSString<Optional> *MerchantId;
@property(nonatomic,strong) NSString<Optional> *CreatedDate;
@property(nonatomic,strong) NSString<Optional> *EndDate;
@property(nonatomic,strong) NSString<Optional> *ServiceUserId;
@property(nonatomic,strong) NSString<Optional> *ServiceUserName;
@property(nonatomic,strong) NSString<Optional> *BrowserTime;
@property(nonatomic,strong) NSString<Optional> *IsSuccess;

@end


@protocol CustomerModel <NSObject>
@end
