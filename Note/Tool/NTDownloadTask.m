//
//  NTDownloadTaskModel.m
//  Note
//
//  Created by lili on 2017/9/28.
//  Copyright © 2017年 HS. All rights reserved.
//

#import "NTDownloadTask.h"
#import "HttpDownloadTool.h"
#import "NSString+MD5.h"

#define IndexDic [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"download.plist"]

#define DownloadDir [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"download"]


//#define DownloadPath [DownloadDir stringByAppendingPathComponent:[self.task.currentRequest.URL.absoluteString md5]]

#define FileInfo [[[NSDictionary alloc]initWithContentsOfFile:IndexDic] objectForKey:[self.task.currentRequest.URL.absoluteString md5]]

@interface NTDownloadTask ()

@end
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
    if (DownloadDir) {
        [[NSFileManager defaultManager]createDirectoryAtPath:DownloadDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSDictionary *dic  = [[NSDictionary alloc]initWithContentsOfFile:IndexDic];
    if (dic) {
        NSString *downloadFilePath = [FileInfo objectForKey:@"path"];
        return downloadFilePath;
    } else {
        NSDictionary *fileInfo = @{[self.task.currentRequest.URL.absoluteString md5]:};
        [fileInfo writeToFile:IndexDic atomically:YES];
    }
    
    return nil;
}



- (NSOutputStream*)outputStream {
    if (_outputStream) {
        return [NSOutputStream outputStreamToFileAtPath:[self filePath] append:YES];
    }
    return _outputStream;
}

- (NSURLSession*)session {
    return nil;
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
