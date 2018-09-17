
#import "AppDelegate+LinkedIn.h"
#import <linkedin-sdk/LISDKCallbackHandler.h>

@implementation AppDelegate (LinkedIn)

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSString *str_url = url.absoluteString;
    NSDictionary *info = [NSBundle mainBundle].infoDictionary;
    NSMutableArray *URLSchemes = info[@"CFBundleURLTypes"];
    __block NSString *li = @"";
    [URLSchemes enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL* _Nonnull stop) {
        NSMutableArray *schemeArray = obj[@"CFBundleURLSchemes"];
        [schemeArray enumerateObjectsUsingBlock:^(NSString * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange result = [line rangeOfString:@"li"];
            if (result.location == 0) {
                li = line;
                *stop = YES;
                return;
            }
        }];
    }];
    NSString *str_linkedin = [NSString stringWithFormat:@"%@://", li];
    NSRange match_linkedin;
    match_linkedin = [str_url rangeOfString: str_linkedin];
    
    //IF LINKEDIN PROTOCOL IS FOUND, POST NOTIFICATION, FIRE LINKEDIN CALLBACK
    if (match_linkedin.location < NSNotFound) {
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:url]];
        if ([LISDKCallbackHandler shouldHandleUrl:url]) {
            return [LISDKCallbackHandler application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
        }
        return YES;
    } else {
        return [super application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    }
}

@end
