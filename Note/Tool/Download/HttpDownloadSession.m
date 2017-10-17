//
//  HttpDownloadTool.m
//  Note
//
//  Created by 王恺靖 on 2017/9/24.
//  Copyright © 2017年 HS. All rights reserved.
//

#import "HttpDownloadSession.h"
#import "NTDownloadFileModel.h"



@interface HttpDownloadSession () <NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionTaskDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSMutableArray<NTDownloadTask*> *taskModelList;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation HttpDownloadSession

+ (HttpDownloadSession*)manager {
    static dispatch_once_t onceToken;
    static HttpDownloadSession *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [HttpDownloadSession new];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        manager.session = [NSURLSession sessionWithConfiguration:config delegate:manager delegateQueue:[[NSOperationQueue alloc] init]];
        manager.taskModelList = [NSMutableArray arrayWithCapacity:0];
        manager.queue = dispatch_queue_create("download.queue", DISPATCH_QUEUE_SERIAL);
    });
    return manager;
}

+ (NSURLSession*)defaulSession{
    return [self manager].session;
}

+ (NSMutableArray<NTDownloadTask*>*)taskList {
    return [self manager].taskModelList;
}

//+ (NTDownloadTask*)download:(NSString*)urlString{
//    NTDownloadTask *task = [[NTDownloadTask alloc]initWithUrl:urlString];
//    [task start];
//    [[self manager].taskModelList addObject:task];
//    return task;
//}

#pragma mark -- Delegate

// sessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NTDownloadTask *tTask= [self seekTaskModel:task];
    if (tTask) {
        [tTask cancel];
        [tTask.model save];
    }
    if (error) {
        NSLog(@"%@",error.domain);
    }
}
// sessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    __block NTDownloadTask *task = [self seekTaskModel:dataTask];
    __block typeof(data) tData = data;
    if (task) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSInteger downloadLength = [task.model writeData:tData];
            if (downloadLength >= 0) {
                task.model.currentLength += downloadLength;
            } else {
                NSLog(@"出错了");
            }
        });
    } else {
        NSLog(@"没找到");
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
    for (NTDownloadTask *model in self.taskModelList) {
        if (task.taskIdentifier == task.taskIdentifier) {
            return model;
        }
    }
    return nil;
}


@end
