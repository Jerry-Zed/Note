//
//  NTDownloadTaskModel.h
//  Note
//
//  Created by lili on 2017/9/28.
//  Copyright © 2017年 HS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTDownloadTask : NSObject;

@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, retain) NSURLSession *session;

@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, assign) NSUInteger downloadLength;
@property (nonatomic, assign) NSUInteger totalLength;
@property (nonatomic, copy) void(^downloadProgress)(float progress);
- (void)continueDownload;
- (void)suspend;
- (void)cancel;
@end
