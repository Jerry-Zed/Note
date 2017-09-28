//
//  HttpDownloadTool.m
//  Note
//
//  Created by 王恺靖 on 2017/9/24.
//  Copyright © 2017年 HS. All rights reserved.
//

#import "HttpDownloadTool.h"


@interface HttpDownloadTool () <NSURLSessionDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableArray<NTDownloadTask*> *taskModelList;
@end

@implementation HttpDownloadTool

+ (HttpDownloadTool*)manager {
    static dispatch_once_t onceToken;
    static HttpDownloadTool *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [HttpDownloadTool new];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        manager.session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
        manager.taskModelList = [NSMutableArray arrayWithCapacity:0];
    });
    return manager;
}

+ (NTDownloadTask*)download:(NSString*)urlString{
    NSURLSession *session = [self manager].session;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
    [task resume];
    NTDownloadTask *model = [NTDownloadTask new];
    model.task = task;
    model.downloadProgress = ^(float progress) {
        NSLog(@"%f",progress);
    };
    [[self manager].taskModelList addObject:model];
    return model;
}

+ (void)removeAll {
    for (int i = 0; i < [self manager].taskModelList.count;) {
        NTDownloadTask *model = [self manager].taskModelList[i];
        [model cancel];
        [[self manager].taskModelList removeObjectAtIndex:i];
    }
}

+ (void)resumeAll {
    for (int i = 0; i < [self manager].taskModelList.count;i++) {
        NTDownloadTask *model = [self manager].taskModelList[i];
        [model resume];
    }
}

+ (void)suspendAll {
    for (int i = 0; i < [self manager].taskModelList.count;) {
        NTDownloadTask *model = [self manager].taskModelList[i];
        [model suspend];
    }
}

@end
