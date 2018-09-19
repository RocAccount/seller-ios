//
//  ContentModel.m
//  SellerPad
//
//  Created by zhuyuming-MAC on 2018/5/7.
//  Copyright © 2018年 zhuyuming-MAC. All rights reserved.
//

#import "ContentModel.h"

@implementation ContentModel
+(BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end

@implementation ContentImage
+(BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end

@implementation ContentImageItem
+(BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end
