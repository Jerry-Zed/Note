//
//  NTHttpTool.m
//  Note
//
//  Created by lili on 2017/9/22.
//  Copyright © 2017年 HS. All rights reserved.
//

#import "HttpTool.h"

@implementation HttpTool
+ (void)requestWith:(NSString*)method url:(NSString*)urlString complete:(void(^)(NSDictionary*))complete {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:configuration];
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer]requestWithMethod:method URLString:urlString parameters:nil error:nil];
    AFHTTPResponseSerializer *response = [AFHTTPResponseSerializer serializer];
    response.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        complete(dict);
    }];
    [dataTask resume];
}

- (NSMutableURLRequest*)requestWith:(NSString*)method url:(NSString*)urlString para:(id)para{
    NSMutableURLRequest *request = nil;
    if ([para isKindOfClass:[NSData class]]) {
        request = [[AFHTTPRequestSerializer serializer]requestWithMethod:method URLString:urlString parameters:nil error:nil];
        request.HTTPBody = para;
    } else if ([para isKindOfClass:[NSDictionary class]]) {
        request = [[AFHTTPRequestSerializer serializer]requestWithMethod:method URLString:urlString parameters:para error:nil];
    }
    [request setAllHTTPHeaderFields:@{
                                      @"content-type":@"application/json",
                                      }];
    return request;
}

+ (AFSecurityPolicy*)sucurityPolicy {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"" ofType:@"cer"];
    NSData *cerData = [NSData dataWithContentsOfFile:path];
    NSSet *certSet = [NSSet setWithObjects:cerData, nil];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:certSet];
//    securityPolicy.validatesDomainName
    return securityPolicy;
    
}
@end
