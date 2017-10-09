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

#define Path [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:[NSString stringWithFormat:@"download/%@",self.model.path]]
@interface NTDownloadTask ()

@end
@implementation NTDownloadTask


- (void)setModel:(NTDownloadFileModel *)model {
    _model = model;
//    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:[NSString stringWithFormat:@"download/%@",model.path]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:Path]) {
        [[NSFileManager defaultManager] createFileAtPath:Path contents:nil attributes:@{NSFileType:model.type}];
    }
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:Path append:YES];
    
    [model addObserver:self forKeyPath:@"currentLength" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [model addObserver:self forKeyPath:@"totalLength" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)cancel {
    [self.task cancel];
    [self.outputStream close];
    self.outputStream = nil;
}


//- (void)continueDownload {
//    self.task = [self.session dataTaskWithURL:[self request] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//
//    }];
//    [self.task resume];
//}
//
//- (void)suspend {
//    [self.task suspend];
//}




- (NSMutableURLRequest*)request {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.task.currentRequest.URL];
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-",  self.model.currentLength];
    [request setValue:range forHTTPHeaderField:@"Range"];
    return request;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"currentLength"]) {
        NSInteger downloadLength = [change[NSKeyValueChangeNewKey] integerValue];
        if (self.model.totalLength && self.downloadProgress) {
            self.downloadProgress(downloadLength * 1.0 / self.model.totalLength);
        }
    }
    if ([keyPath isEqualToString:@"totalLength"]) {
        NSInteger totalLength = [change[NSKeyValueChangeNewKey] integerValue];
        BOOL sucess = [[NSFileManager defaultManager]setAttributes:@{NSFileSize:@(totalLength)} ofItemAtPath:Path error:nil];
        if (totalLength && self.downloadProgress) {
            self.downloadProgress(self.model.currentLength * 1.0 / totalLength);
        }
    }
}

@end
