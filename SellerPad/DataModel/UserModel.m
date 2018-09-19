//
//  UserModel.m
//  SellerPad
//
//  Created by zhuyuming-MAC on 2018/5/7.
//  Copyright © 2018年 zhuyuming-MAC. All rights reserved.
//

#import "UserModel.h"

@implementation LoginUserModel
-(id)init{
    if(self=[super init]){
        
    }
    return self;
}
+(BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end
@implementation UserModel
-(id)init{
    if(self=[super init]){
        
    }
    return self;
}
+(BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end
