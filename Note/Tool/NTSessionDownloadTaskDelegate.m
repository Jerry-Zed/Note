//
//  NTSessionDownloadTaskDelegate.m
//  Note
//
//  Created by lili on 2017/9/28.
//  Copyright © 2017年 HS. All rights reserved.
//

#import "NTSessionDownloadTaskDelegate.h"
@interface NTSessionDownloadTaskDelegate ()

@end
@implementation NTSessionDownloadTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NTDownloadTask *model = [self seekTaskModel:task];
    if (model) {
        [model.outputStream close];
        model.outputStream = nil;
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    __block NTDownloadTask *model = [self seekTaskModel:dataTask];
    if (model) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [model.outputStream write:data.bytes maxLength:data.length];
            model.downloadLength += data.length;
        });
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    NTDownloadTask *model = [self seekTaskModel:dataTask];
    if (model) {
        model.totalLength = model.downloadLength + response.expectedContentLength;
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
