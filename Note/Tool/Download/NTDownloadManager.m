//
//  NTDownloadManager.m
//  Note
//
//  Created by lili on 2017/10/23.
//  Copyright © 2017年 HS. All rights reserved.
//

#import "NTDownloadManager.h"
#import "HttpDownloadSession.h"
#import "NSURLSessionDataTask+NTDownload.h"

@interface NTDownloadManager ()
@property (nonatomic, strong) NSURLSessionDataTask *task;
@end
@implementation NTDownloadManager
- (instancetype)initWithUrl:(NSString*)url
{
    self = [super init];
    if (self) {
        NTDownloadFileModel *model = [NTDownloadFileModel instanceWith:[NSURL URLWithString:url]];
        NSMutableURLRequest *request = [NTDownloadManager request:model.url startLength:model.currentLength];
        self.task = [[HttpDownloadSession defaulSession] dataTaskWithRequest:request];
        [self.task setNt_model:model];
        [self setValue:model forKey:@"fileModel"];
    }
    return self;
}

- (instancetype)initWithModel:(NTDownloadFileModel*)model
{
    self = [super init];
    if (self) {
        NSMutableURLRequest *request = [NTDownloadManager request:model.url startLength:model.currentLength];
        self.task = [[HttpDownloadSession defaulSession] dataTaskWithRequest:request];
        [self.task setNt_model:model];
        [self setValue:model forKey:@"fileModel"];
    }
    return self;
}

- (void)start{
    if (self.task == nil) {
        NSMutableURLRequest *request = [NTDownloadManager request:self.fileModel.url startLength:self.fileModel.currentLength];
        self.task =  [[HttpDownloadSession defaulSession] dataTaskWithRequest:request];
        [self.task setNt_model:self.fileModel];
    }
    [self.task resume];
    [self setValue:@(1) forKey:@"status"];
}


- (void)cancel {
    [self setValue:@(0) forKey:@"status"];
    [self.task.nt_model stopWrite];
    [self.task cancel];
    self.task = nil;
}

- (void)setFileModel:(NTDownloadFileModel *)fileModel {
    _fileModel = fileModel;
    [fileModel addObserver:self forKeyPath:@"currentLength" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [fileModel addObserver:self forKeyPath:@"totalLength" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentLength"]) {
        NSInteger downloadLength = [change[NSKeyValueChangeNewKey] integerValue];
        if (self.fileModel.totalLength && self.downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.downloadProgress(downloadLength * 1.0 / self.fileModel.totalLength);
            });
        }
//        NSLog(@"文件大小%ld",(long)downloadLength);
    }
    if ([keyPath isEqualToString:@"totalLength"]) {
        NSInteger totalLength = [change[NSKeyValueChangeNewKey] integerValue];
        if (totalLength && self.downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.downloadProgress(self.fileModel.currentLength * 1.0 / totalLength);
            });
        }
    }
}

+ (NSMutableURLRequest*)request:(NSString*)url startLength:(NSInteger)startLength {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-",  startLength];
    [request setValue:range forHTTPHeaderField:@"Range"];
    return request;
}


@end
