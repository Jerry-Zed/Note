//
//  NSURLSessionDataTask+NTDownloadModel.h
//  Note
//
//  Created by lili on 2017/10/23.
//  Copyright © 2017年 HS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTDownloadFileModel.h"

@interface NSURLSessionDataTask (NTDownload)
@property (nonatomic, strong) NTDownloadFileModel *model;
@end
