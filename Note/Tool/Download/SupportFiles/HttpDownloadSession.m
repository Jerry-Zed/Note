//
//  HttpDownloadTool.m
//  Note
//
//  Created by 王恺靖 on 2017/9/24.
//  Copyright © 2017年 HS. All rights reserved.
//

#import "HttpDownloadSession.h"
#import "NTDownloadFileModel.h"
#import "NSURLSessionDataTask+NTDownload.h"
static dispatch_queue_t serial_queue () {
    static dispatch_once_t onceToken;
    static dispatch_queue_t queue;
    dispatch_once(&onceToken, ^{
      queue = dispatch_queue_create("download.queue", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

@interface HttpDownloadSession () <NSURLSessionDelegate,NSURLSessionDataDelegate,NSURLSessionTaskDelegate>
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation HttpDownloadSession

+ (HttpDownloadSession*)manager {
    static dispatch_once_t onceToken;
    static HttpDownloadSession *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [HttpDownloadSession new];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        manager.session = [NSURLSession sessionWithConfiguration:config delegate:manager delegateQueue:[[NSOperationQueue alloc] init]];
    });
    return manager;
}

+ (NSURLSession*)defaulSession{
    return [self manager].session;
}



#pragma mark -- Delegate

// sessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (task.nt_model) {
        [task cancel];
        [task.nt_model save];
        NSLog(@"完成");
    }
    if (error) {
        NSLog(@"%@",error.domain);
    }
}
// sessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    __block typeof(data) tData = data;
    if (dataTask.nt_model) {
        
        dispatch_async(serial_queue(), ^{
            NSInteger downloadLength = [dataTask.nt_model writeData:tData];
            if (downloadLength >= 0) {
//                task.model.currentLength += downloadLength;
            } else {
//                NSLog(@"出错了");
            }
        });
    } else {
        NSLog(@"没找到");
    }
}
// sessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    if (dataTask.nt_model) {
        dataTask.nt_model.totalLength = dataTask.nt_model.currentLength + response.expectedContentLength;
    }
    completionHandler(NSURLSessionResponseAllow);
}
//
//- (NTDownloadTask*)seekTaskModel:(NSURLSessionTask*)task {
//    for (NTDownloadTask *model in self.taskModelList) {
//        if (task.taskIdentifier == task.taskIdentifier) {
//            return model;
//        }
//    }
//    return nil;
//}


@end
