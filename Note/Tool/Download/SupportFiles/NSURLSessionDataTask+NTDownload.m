//
//  NSURLSessionDataTask+NTDownloadModel.m
//  Note
//
//  Created by lili on 2017/10/23.
//  Copyright © 2017年 HS. All rights reserved.
//

#import "NSURLSessionDataTask+NTDownload.h"
#import <objc/runtime.h>
@implementation NSObject (NTDownload)

- (void)setNt_model:(NTDownloadFileModel *)nt_model{
    objc_setAssociatedObject(self, @selector(nt_model), nt_model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NTDownloadFileModel*)nt_model {
    return objc_getAssociatedObject(self, _cmd);
}

@end
