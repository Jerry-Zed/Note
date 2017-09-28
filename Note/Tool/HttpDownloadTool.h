//
//  HttpDownloadTool.h
//  Note
//
//  Created by 王恺靖 on 2017/9/24.
//  Copyright © 2017年 HS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTDownloadTask.h"
@interface HttpDownloadTool : NSObject
+ (void)removeAll;
+ (void)resumeAll;
+ (void)suspendAll;
+ (NTDownloadTask*)download:(NSString*)urlString;
@end
