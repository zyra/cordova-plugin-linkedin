#import "AppDelegate+LinkedIn.h"
#import <linkedin-sdk/LISDKCallbackHandler.h>

@implementation AppDelegate (LinkedIn)

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([LISDKCallbackHandler shouldHandleUrl:url]) {
        return [LISDKCallbackHandler application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    } else {
        // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:url]];
    }
    return YES;
}

@end
