//
//  NTDownloadFileModel.h
//  Note
//
//  Created by lili on 2017/9/29.
//  Copyright © 2017年 HS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTDownloadFileModel : NSObject <NSCoding>
@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) NSInteger currentLength;
@property (nonatomic, assign) NSInteger totalLength;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *url;

+ (instancetype)instanceWith:(NSURL*)url;

- (void)save;                // 保存信息到下载列表
+ (NSMutableArray*)readList;       // 下载列表

@end
