//
//  UserModel.h
//  SellerPad
//
//  Created by zhuyuming-MAC on 2018/5/7.
//  Copyright © 2018年 zhuyuming-MAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
@interface LoginUserModel:JSONModel
@property(nonatomic,assign) long UserId;
@property(nonatomic,strong) NSString<Optional>* NickName;
@property(nonatomic,assign) NSString<Optional>* MerchantId;
@property(nonatomic,assign) long StoreId;
@property(nonatomic,assign) int Type;
@property(nonatomic,strong) NSString<Optional>* Token;
@property(nonatomic,strong) NSString<Optional>* UserName;
//@property(nonatomic,strong) NSString<Optional> *Password;
//@property(nonatomic,strong) NSString<Optional>* MerchantName;
@property(nonatomic,strong) NSString<Optional>* StoreName;

@end
@protocol LoginUserModel <NSObject>
@end

@interface UserModel:JSONModel
@property(nonatomic,assign) long Id;
@property(nonatomic,strong) NSString<Optional>* NickName;
@property(nonatomic,assign) NSString<Optional>* MerchantId;
@property(nonatomic,strong) NSString<Optional>* StoreId;
@property(nonatomic,strong) NSString<Optional>* Type;
@property(nonatomic,strong) NSString<Optional>* Description;
@property(nonatomic,strong) NSString<Optional>* State;
@property(nonatomic,strong) NSString<Optional>* Name;
@property(nonatomic,strong) NSString<Optional> *Password;
@property(nonatomic,strong) NSString<Optional>* Sex;
@property(nonatomic,strong) NSString<Optional>* Email;
@property(nonatomic,strong) NSString<Optional>* Tel;
@property(nonatomic,strong) NSString<Optional>* MerchantName;
@property(nonatomic,strong) NSString<Optional>* StoreName;

@end
@protocol UserModel <NSObject>
@end
