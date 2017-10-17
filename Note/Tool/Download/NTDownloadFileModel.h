//
//  NTDownloadFileModel.h
//  Note
//
//  Created by lili on 2017/9/29.
//  Copyright © 2017年 HS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTDownloadConfig.h"

@interface NTDownloadFileModel : NSObject <NSCoding>
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger currentLength;
@property (nonatomic, assign) NSInteger totalLength;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *url;

+ (instancetype)instanceWith:(NSURL*)url;

- (void)save;                               // 保存信息到下载列表
- (void)del;
- (NSInteger)writeData:(NSData*)data;       // 写入数据
- (void)stopWrite;                          // 停止写入
+ (NSMutableArray*)readList;                // 下载列表

@end
