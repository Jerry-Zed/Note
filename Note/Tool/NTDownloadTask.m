//
//  NTDownloadTaskModel.m
//  Note
//
//  Created by lili on 2017/9/28.
//  Copyright © 2017年 HS. All rights reserved.
//

#import "NTDownloadTask.h"

@implementation NTDownloadTask

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:@"downloadLength" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        [self addObserver:self forKeyPath:@"totalLength" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (void)cancel {
    [self.task cancel];
    [self.outputStream close];
    self.outputStream = nil;
}

- (void)continueDownload {
    self.task = [self.session dataTaskWithURL:[self request] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
    [self.task resume];
}

- (void)suspend {
    [self.task suspend];
}

- (NSString*)filePath {
    NSString *dir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *plistPath = [dir stringByAppendingPathComponent:@"download.plist"];
    NSString *downDir = [dir stringByAppendingPathComponent:@"download"];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:plistPath]) {
        [manager createFileAtPath:plistPath contents:nil attributes:nil];
    }
    if (![manager fileExistsAtPath:downDir]) {
        [manager createDirectoryAtPath:downDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithContentsOfFile:plistPath];
    NSDictionary *fileInfo = [dic objectForKey:self.task.currentRequest.URL.absoluteString];
    if (!fileInfo) {
        
    }
    NSString *filePath = [fileInfo objectForKey:@"path"];
    if (![[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager]createFileAtPath:filePath contents:nil attributes:nil];
    }
    return filePath;
}

- (NSOutputStream*)outputStream {
    if (_outputStream) {
        return [NSOutputStream outputStreamToFileAtPath:[self filePath] append:YES];
    }
    return _outputStream;
}
- (NSUInteger)downloadLength {
    if (self.task.state == NSURLSessionTaskStateCanceling) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingString:@""];
        return [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
    }
    
    return _downloadLength;
}

- (NSMutableURLRequest*)request {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.task.currentRequest.URL];
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-",  self.downloadLength];
    [request setValue:range forHTTPHeaderField:@"Range"];
    return request;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"downloadLength"]) {
        NSInteger downloadLength = [change[NSKeyValueChangeNewKey] integerValue];
        if (self.totalLength && self.downloadProgress) {
            self.downloadProgress(downloadLength * 1.0 / self.totalLength);
        }
    }
    if ([keyPath isEqualToString:@"totalLength"]) {
        NSInteger totalLength = [change[NSKeyValueChangeNewKey] integerValue];
        if (totalLength && self.downloadProgress) {
            self.downloadProgress(self.downloadLength * 1.0 / totalLength);
        }
    }
}

@end
