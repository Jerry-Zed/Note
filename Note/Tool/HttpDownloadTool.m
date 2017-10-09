//
//  HttpDownloadTool.m
//  Note
//
//  Created by 王恺靖 on 2017/9/24.
//  Copyright © 2017年 HS. All rights reserved.
//

#import "HttpDownloadTool.h"
#import "NTDownloadFileModel.h"
//#import "NTSessionDownloadTaskDelegate.h"


@interface HttpDownloadTool () <NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionTaskDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableArray<NTDownloadTask*> *taskModelList;
//@property (nonatomic, strong) NTSessionDownloadTaskDelegate *delegate;
@end

@implementation HttpDownloadTool

+ (HttpDownloadTool*)manager {
    static dispatch_once_t onceToken;
    static HttpDownloadTool *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [HttpDownloadTool new];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        manager.session = [NSURLSession sessionWithConfiguration:config delegate:manager delegateQueue:[[NSOperationQueue alloc] init]];
        manager.taskModelList = [NSMutableArray arrayWithCapacity:0];
    });
    return manager;
}


+ (NTDownloadTask*)download:(NSString*)urlString{
    NSURLSession *session = [self manager].session;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLSessionDataTask *sessionTask = [session dataTaskWithRequest:request];
    [sessionTask resume];
    NTDownloadTask *task = [NTDownloadTask new];
    NTDownloadFileModel *model = [NTDownloadFileModel instanceWith:[NSURL URLWithString:urlString]];
    task.model = model;
    task.task = sessionTask;
    task.session = session;
    task.downloadProgress = ^(float progress) {
        NSLog(@"%f",progress);
    };
    
    [[self manager].taskModelList addObject:task];
    return task;
}

#pragma mark -- Delegate

// sessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NTDownloadTask *tTask= [self seekTaskModel:task];
    if (tTask) {
        [tTask.outputStream close];
        tTask.outputStream = nil;
        [tTask.model save];
    }
}
// sessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    __block NTDownloadTask *task = [self seekTaskModel:dataTask];
    if (task) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [task.outputStream write:data.bytes maxLength:data.length];
            task.model.currentLength += data.length;
        });
    }
}
// sessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NTDownloadTask *task = [self seekTaskModel:dataTask];
    if (task) {
        task.model.totalLength = task.model.currentLength + response.expectedContentLength;
    }
    completionHandler(NSURLSessionResponseAllow);
}

- (NTDownloadTask*)seekTaskModel:(NSURLSessionTask*)task {
    //    NSURLSessionDataTask *dataTask = task;
    for (NTDownloadTask *model in self.taskModelList) {
        if (model.task.taskIdentifier == task.taskIdentifier) {
            return model;
        }
    }
    return nil;
}


@end
