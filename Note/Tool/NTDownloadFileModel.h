//
//  NTDownloadFileModel.h
//  Note
//
//  Created by lili on 2017/9/29.
//  Copyright © 2017年 HS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTDownloadFileModel : NSObject
@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) NSInteger totalLength;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *url;
@end
