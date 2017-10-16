//
//  NTDownloadTaskModel.h
//  Note
//
//  Created by lili on 2017/9/28.
//  Copyright © 2017年 HS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTDownloadFileModel.h"

@interface NTDownloadTask : NSObject;

@property (readonly) NSInteger status;   // 0 未开始  1 正在下载
@property (nonatomic, strong) NTDownloadFileModel *model;
@property (readonly) NSUInteger    taskIdentifier;
@property (nonatomic, copy) void(^downloadProgress)(float progress);

- (instancetype)initWithUrl:(NSString*)url;
- (instancetype)initWithModel:(NTDownloadFileModel*)model;

- (void)start;
- (void)cancel;

@end
