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

@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NTDownloadFileModel *model;
@property (readonly) NSUInteger    taskIdentifier;

@property (nonatomic, copy) void(^downloadProgress)(float progress);

- (void)cancel;
- (void)startWithUrl:(NSString*)url;
@end
