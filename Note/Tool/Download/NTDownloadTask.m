//
//  NTDownloadTaskModel.m
//  Note
//
//  Created by lili on 2017/9/28.
//  Copyright © 2017年 HS. All rights reserved.
//

#import "NTDownloadTask.h"
#import "HttpDownloadSession.h"
#import "NSString+MD5.h"


@interface NTDownloadTask () <NSStreamDelegate>
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, strong) NSLock* lock;
@end
@implementation NTDownloadTask

- (void)dealloc {
    [_model stopWrite];
    [_task cancel];
    _task = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lock = [[NSLock alloc]init];
    }
    return self;
}

- (instancetype)initWithUrl:(NSString*)url
{
    self = [super init];
    if (self) {
        NTDownloadFileModel *model = [NTDownloadFileModel instanceWith:[NSURL URLWithString:url]];
        self.lock = [[NSLock alloc]init];
        self.url = url;
        self.model = model;
        self.task = [[HttpDownloadSession defaulSession] dataTaskWithRequest:self.request];
        [self setValue:@(self.task.taskIdentifier) forKey:@"taskIdentifier"];
    }
    return self;
}

- (instancetype)initWithModel:(NTDownloadFileModel*)model
{
    self = [super init];
    if (self) {
        self.lock = [[NSLock alloc]init];
        self.model = model;
        self.url = model.url;
        self.task = [[HttpDownloadSession defaulSession] dataTaskWithRequest:self.request];
        [self setValue:@(self.task.taskIdentifier) forKey:@"taskIdentifier"];
    }
    return self;
}

- (void)setModel:(NTDownloadFileModel *)model {
    _model = model;
    [model addObserver:self forKeyPath:@"currentLength" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [model addObserver:self forKeyPath:@"totalLength" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)start{
    if (self.task == nil) {
        self.task = [[HttpDownloadSession defaulSession] dataTaskWithRequest:self.request];
    }
    [self.task resume];
    [self setValue:@(1) forKey:@"status"];
    [[HttpDownloadSession taskList] addObject:self];
}

//- (void)suspend {
//    [self.task suspend];
//    [self setValue:@(2) forKey:@"status"];
//}



- (void)cancel {
    [self setValue:@(0) forKey:@"status"];
    [self.model stopWrite];
    [self.task cancel];
    self.task = nil;
}


- (NSMutableURLRequest*)request {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-",  self.model.currentLength];
    [request setValue:range forHTTPHeaderField:@"Range"];
    return request;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentLength"]) {
        NSInteger downloadLength = [change[NSKeyValueChangeNewKey] integerValue];
        if (self.model.totalLength && self.downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.downloadProgress(downloadLength * 1.0 / self.model.totalLength);
            });
        }
    }
    if ([keyPath isEqualToString:@"totalLength"]) {
        NSInteger totalLength = [change[NSKeyValueChangeNewKey] integerValue];
        if (totalLength && self.downloadProgress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.downloadProgress(self.model.currentLength * 1.0 / totalLength);
            });
        }
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
//    NSLog(@"%lu",(unsigned long)eventCode);
}

@end
