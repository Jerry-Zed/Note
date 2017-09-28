//
//  NTSessionDownloadTaskDelegate.h
//  Note
//
//  Created by lili on 2017/9/28.
//  Copyright © 2017年 HS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTDownloadTask.h"
@interface NTSessionDownloadTaskDelegate : NSObject
@property (nonatomic, copy) void(^completeHandle)(NSString*);
@property (nonatomic, strong) NSMutableArray<NTDownloadTask*> *taskModelList;
@end
