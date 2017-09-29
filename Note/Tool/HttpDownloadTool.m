//
//  HttpDownloadTool.m
//  Note
//
//  Created by 王恺靖 on 2017/9/24.
//  Copyright © 2017年 HS. All rights reserved.
//

#import "HttpDownloadTool.h"
#import "NTSessionDownloadTaskDelegate.h"


@interface HttpDownloadTool () <NSURLSessionDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableArray<NTDownloadTask*> *taskModelList;
@property (nonatomic, strong) NTSessionDownloadTaskDelegate *delegate;
@end

@implementation HttpDownloadTool

+ (HttpDownloadTool*)manager {
    static dispatch_once_t onceToken;
    static HttpDownloadTool *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [HttpDownloadTool new];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        manager.delegate = [NTSessionDownloadTaskDelegate new];
        manager.delegate.taskModelList = manager.taskModelList;
        manager.session = [NSURLSession sessionWithConfiguration:config delegate:manager.delegate delegateQueue:[[NSOperationQueue alloc] init]];
        manager.taskModelList = [NSMutableArray arrayWithCapacity:0];
    });
    return manager;
}


+ (NTDownloadTask*)download:(NSString*)urlString{
    NSURLSession *session = [self manager].session;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    [task resume];
    NTDownloadTask *model = [NTDownloadTask new];
    model.task = task;
    model.session = [self manager].session;
    model.downloadProgress = ^(float progress) {
        NSLog(@"%f",progress);
    };
    [[self manager].taskModelList addObject:model];
    return model;
}


@end
