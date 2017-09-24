//
//  NTHttpTool.m
//  Note
//
//  Created by lili on 2017/9/22.
//  Copyright © 2017年 HS. All rights reserved.
//

#import "HttpRequestTool.h"
#import "HTTPCredential.h"

@implementation HttpRequestTool

+ (AFURLSessionManager*)manager {
    static AFURLSessionManager *manager = nil;
    dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:configuration];
        manager.securityPolicy = [self securityPolicy];
        manager.responseSerializer = [self response];
        [manager setTaskDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLAuthenticationChallenge * _Nonnull challenge, NSURLCredential *__autoreleasing  _Nullable * _Nullable credential) {
            *credential = [HTTPCredential getAuthenticationFromP12:@"" pwd:@""];
            return NSURLSessionAuthChallengeUseCredential;
        }];
    });
    return manager;
}

+ (void)requestWith:(NSString*)method url:(NSString*)urlString complete:(void(^)(NSDictionary*))complete {
    AFURLSessionManager *manager= [self manager];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer]requestWithMethod:method URLString:urlString parameters:nil error:nil];
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

+ (AFSecurityPolicy*)securityPolicy {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"" ofType:@"cer"];
    NSData *cerData = [NSData dataWithContentsOfFile:path];
    NSSet *certSet = [NSSet setWithObjects:cerData, nil];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:certSet];
    securityPolicy.validatesDomainName = NO;
    securityPolicy.allowInvalidCertificates = YES;
    return securityPolicy;
}

+ (AFHTTPResponseSerializer*)response {
    AFHTTPResponseSerializer *response = [AFHTTPResponseSerializer serializer];
    response.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    return response;
}
@end
