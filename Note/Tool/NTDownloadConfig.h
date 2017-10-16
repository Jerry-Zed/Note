//
//  NTDownloadConfig.h
//  Note
//
//  Created by lili on 2017/10/16.
//  Copyright © 2017年 HS. All rights reserved.
//


#define DownloadDir             [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"download"]
#define DownloadList            [DownloadDir stringByAppendingPathComponent:@"index.plist"]
#define AllowExistSameFile      NO

