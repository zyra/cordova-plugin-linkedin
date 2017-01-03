#import <Cordova/CDV.h>
#import "LinkedIn.h"
#import <linkedin-sdk/LISDKSessionManager.h>
#import <linkedin-sdk/LISDKAPIHelper.h>
#import <linkedin-sdk/LISDKAPIResponse.h>
#import <linkedin-sdk/LISDKAPIError.h>
#import <linkedin-sdk/LISDKAccessToken.h>

@implementation LinkedIn

NSString* const API_URL = @"https://api.linkedin.com/v1/";

- (void (^)(LISDKAPIError*)) getError:(CDVInvokedUrlCommand*)command
{
    return ^(LISDKAPIError* error)
    {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    };
}

- (void)login:(CDVInvokedUrlCommand*)command
{
    
    NSArray* scopes = [command.arguments objectAtIndex:0];
    bool promptToInstall = [[command.arguments objectAtIndex:1] boolValue];
    
    [LISDKSessionManager createSessionWithAuth:scopes state:nil showGoToAppStoreDialog:promptToInstall successBlock:^(NSString *response) {
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        
    } errorBlock:^(NSError *error) {
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        
    }];
    
}

- (void)logout:(CDVInvokedUrlCommand*)command
{
    [LISDKSessionManager clearSession];
}

- (void)getRequest:(CDVInvokedUrlCommand*)command
{
    NSMutableString* path = [[NSMutableString alloc] init];
    [path appendString:API_URL];
    [path appendString:[command.arguments objectAtIndex:0]];
    //NSString* path = [command.arguments objectAtIndex:0];
    NSLog(@"%s: %@", "Doing a get request to url", path);
    
    [[LISDKAPIHelper sharedInstance] getRequest:[command.arguments objectAtIndex:0] success:^(LISDKAPIResponse * response) {
        
    } error:[self getError:command]];
}

- (void)postRequest:(CDVInvokedUrlCommand*)command
{
    [[LISDKAPIHelper sharedInstance] postRequest:[command.arguments objectAtIndex:0] body:[command.arguments objectAtIndex:1] success:^(LISDKAPIResponse * response) {
        
    } error:[self getError:command]];
}

- (void)openProfile:(CDVInvokedUrlCommand*)command
{
    
}

@end
