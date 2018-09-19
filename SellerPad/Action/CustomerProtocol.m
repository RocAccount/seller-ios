//
//  CustomerProtocol.m
//  SellerPad
//
//  Created by zhuyuming-MAC on 2018/6/7.
//  Copyright © 2018年 zhuyuming-MAC. All rights reserved.
//

#import "CustomerProtocol.h"
static NSString * const JWURLProtocolHandledKey = @"JWURLProtocolHandledKey";

@implementation CustomerProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
    NSLog(@"inrequest:%@",[request URL]);
    //只处理http和https请求
    NSString *scheme = [[request URL] scheme];
    NSLog(@"HEAD:%@",request.allHTTPHeaderFields);
    if (([scheme caseInsensitiveCompare:@"filelocal"] == NSOrderedSame||
         [scheme caseInsensitiveCompare:@"unsafe"] == NSOrderedSame||[scheme caseInsensitiveCompare:@"inrequest"] == NSOrderedSame))
    {
        //看看是否已经处理过了，防止无限循环
        if ([NSURLProtocol propertyForKey:JWURLProtocolHandledKey inRequest:request]) {
            return NO;
        }
        else if(![request.URL.absoluteString containsString:@"filelocal:"]){
            return NO;
        }
        return YES;
    }
    return NO;
}

+ (NSURLRequest *) canonicalRequestForRequest:(NSURLRequest *)request {
    /** 可以在此处添加头等信息  */
    //    NSMutableURLRequest *mutableReqeust = [request mutableCopy];
    //    mutableReqeust = [self redirectHostInRequset:mutableReqeust];
    //    return mutableReqeust;
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading
{
    NSMutableURLRequest *mutableReqeust = [[self request] mutableCopy];
    //打标签，防止无限循环
    [NSURLProtocol setProperty:@YES forKey:JWURLProtocolHandledKey inRequest:mutableReqeust];
    NSString *address = [mutableReqeust.URL.absoluteString stringByReplacingOccurrencesOfString:@"unsafe:" withString:@""];
    address = [address stringByReplacingOccurrencesOfString:@"inrequest://" withString:@""];
    address = [address stringByReplacingOccurrencesOfString:@"filelocal://" withString:@""];
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *homePath = array.firstObject;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dataPath = [homePath stringByAppendingPathComponent:address];
    
    //异步
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:mutableReqeust queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

        if(![fileManager fileExistsAtPath:dataPath])
        {
            NSLog(@"SSSSSSSSSSSSS:%@",dataPath);
            [self mockRequest:mutableReqeust data:nil];
        }
        else
        {
            NSLog(@"dataPath:%@",dataPath);
            NSData *da = [NSData dataWithContentsOfFile:dataPath];
            
            //NSData *d = [da subdataWithRange:NSMakeRange(0, 1065)];
            [self mockRequest:mutableReqeust data:da];
        }
        
    }];
    
    //    同步
    //    NSHTTPURLResponse* urlResponse = nil;
    //    NSError *error = [[NSError alloc] init];
    //    NSData *data =[NSURLConnection sendSynchronousRequest:mutableRequest returningResponse:&urlResponse error:&error];
    //    [self mockRequest:mutableRequest data:data];
    
}

#pragma mark - Mock responses

-(void) mockRequest:(NSURLRequest*)request data:(NSData*)data {
    id client = [self client];
    
    //    问题来自于webkit块因为起源于跨域请求的响应。因为我们我们必须迫使Access-Control-Allow-Origin模拟响应，然后我们还需要强迫响应的内容类型。
    //    设置为*则所域可以用ajax跨域获取数据，设置为指定的域名只能指定的域名用ajax跨域获取到数据。
    
    NSLog(@"HEAD:%@",request.allHTTPHeaderFields[@"Range"]);
    
    NSDictionary *headers = @{@"Access-Control-Allow-Origin" : @"*", @"Access-Control-Allow-Headers" : @"Content-Type"};
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"1.0" headerFields:headers];
    
    [client URLProtocol:self didReceiveResponse:response
     cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [client URLProtocol:self didLoadData:data];
    [client URLProtocolDidFinishLoading:self];
}
- (void)stopLoading
{

}

@end
