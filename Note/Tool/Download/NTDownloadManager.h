//
//  NTDownloadManager.h
//  Note
//
//  Created by lili on 2017/10/23.
//  Copyright © 2017年 HS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTDownloadFileModel.h"

@interface NTDownloadManager : NSObject
@property (readonly) NSInteger status;   // 0 未开始  1 正在下载
@property (readonly) NTDownloadFileModel *fileModel;
@property (nonatomic, copy) void(^downloadProgress)(float progress);

- (instancetype)initWithUrl:(NSString*)url;
- (instancetype)initWithModel:(NTDownloadFileModel*)model;

- (void)start;
- (void)cancel;
@end
