//
//  NSURLSessionDataTask+NTDownloadModel.m
//  Note
//
//  Created by lili on 2017/10/23.
//  Copyright © 2017年 HS. All rights reserved.
//

#import "NSURLSessionDataTask+NTDownload.h"
#import <objc/runtime.h>
@implementation NSURLSessionDataTask (NTDownload)

- (void)setModel:(NTDownloadFileModel *)model {
    objc_setAssociatedObject(self, @selector(model), model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NTDownloadFileModel*)model {
    return objc_getAssociatedObject(self, _cmd);
}

@end
