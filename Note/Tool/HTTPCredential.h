//
//  HTTPCredential.h
//  Note
//
//  Created by lili on 2017/9/22.
//  Copyright © 2017年 HS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPCredential : NSObject
+ (NSURLCredential *)getAuthenticationFromP12:(NSString*)path pwd:(NSString*)pwd;
@end
