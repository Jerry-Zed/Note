//
//  HTTPCredential.m
//  Note
//
//  Created by lili on 2017/9/22.
//  Copyright © 2017年 HS. All rights reserved.
//

#import "HTTPCredential.h"

@implementation HTTPCredential
+ (NSURLCredential *)getAuthenticationFromP12:(NSString*)path pwd:(NSString*)pwd
{
    NSString *thePath = path;
    NSData *PKCS12Data = [[NSData alloc] initWithContentsOfFile:thePath];
    
    CFDataRef inPKCS12Data = (__bridge CFDataRef)PKCS12Data;
    
    SecIdentityRef identity = NULL;
    
    CFStringRef password = (__bridge CFStringRef)pwd;
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { password };
    
    CFDictionaryRef options = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    
    OSStatus securityError = errSecSuccess;
    securityError = SecPKCS12Import(inPKCS12Data, options, &items);
    
    
    
    if (securityError == 0)
    {
        CFDictionaryRef ident = CFArrayGetValueAtIndex(items,0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue(ident, kSecImportItemIdentity);
        identity = (SecIdentityRef)tempIdentity;
    }
    
    
    SecCertificateRef certificate = NULL;
    SecIdentityCopyCertificate (identity, &certificate);
    
    NSURLCredential *credential = [NSURLCredential credentialWithIdentity:identity certificates:nil persistence:NSURLCredentialPersistencePermanent];
    if (options) {
        CFRelease(options);
    }
    
    if (items) {
        CFRelease(items);
    }
    CFRelease(certificate);
    return credential;
}
@end
