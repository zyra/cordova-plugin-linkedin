#import <Cordova/CDV.h>
#import "LinkedIn.h"
#import <linkedin-sdk/LISDKSessionManager.h>
#import <linkedin-sdk/LISDKSession.h>
#import <linkedin-sdk/LISDKAPIHelper.h>
#import <linkedin-sdk/LISDKAPIResponse.h>
#import <linkedin-sdk/LISDKAPIError.h>
#import <linkedin-sdk/LISDKAccessToken.h>
#import <linkedin-sdk/LISDKDeeplinkHelper.h>

@implementation LinkedIn

NSString* const API_URL = @"https://api.linkedin.com/v1/";

// convenience method to handle errors on most of the LinkedIn SDK methods
- (void (^)(LISDKAPIError*)) getError:(CDVInvokedUrlCommand*)command
{
    return ^(LISDKAPIError* error)
    {
        NSLog(@"ERROR IS %@", error);
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    };
}

- (void)login:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        
        // get the requested scopes for login
        NSArray* const scopes = [command.arguments objectAtIndex:0];
        // set promptToInstall property
        bool const promptToInstall = [[command.arguments objectAtIndex:1] boolValue];
        
        // create LinkedIn session
        [LISDKSessionManager createSessionWithAuth:scopes state:nil showGoToAppStoreDialog:promptToInstall successBlock:^(NSString* response) {
            
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            
        } errorBlock:^(NSError *error) {
            
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            
        }];
    }];
}

- (void)logout:(CDVInvokedUrlCommand*)command
{
    [LISDKSessionManager clearSession];
}

- (void (^)(LISDKAPIResponse*))handleAPIResponse:(CDVInvokedUrlCommand*) command
{
    return ^(LISDKAPIResponse* response) {
        NSError *jsonError;
        NSData *objectData = [response.data dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:&jsonError];
        CDVPluginResult *result;
        
        if (jsonError != nil) {
            // return response data as string
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:response.data];
        } else {
            // return response data as json
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:json];
        }
        
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    };
}

- (NSString*)getRequestURL: (NSString *)path
{
    NSMutableString* url = [[NSMutableString alloc] init];
    [url appendString:API_URL];
    [url appendString:path];
    return url;
}

- (void)getRequest:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        [[LISDKAPIHelper sharedInstance] getRequest:[self getRequestURL:[command.arguments objectAtIndex:0]] success:[self handleAPIResponse:command] error:[self getError:command]];
    }];
}

- (NSData*)getRequestData:(NSDictionary*) inputDictionary
{
    NSData* resultData;
    NSError* parseError;
    if([NSJSONSerialization isValidJSONObject:inputDictionary]) {
        resultData = [NSJSONSerialization dataWithJSONObject:inputDictionary options:0 error:&parseError];
    }
    return resultData;
}

- (void)postRequest:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        [[LISDKAPIHelper sharedInstance] postRequest:[self getRequestURL:[command.arguments objectAtIndex:0]] body:[self getRequestData:[command.arguments objectAtIndex:1]] success:[self handleAPIResponse:command] error:[self getError:command]];
    }];
}

- (void)openProfile:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        DeeplinkSuccessBlock success = ^(NSString *returnState) {
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        };
        
        DeeplinkErrorBlock error = ^(NSError *error, NSString *returnState) {
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        };
        
        [[LISDKDeeplinkHelper sharedInstance] viewOtherProfile:[command.arguments objectAtIndex:0] withState:@"viewMemberProfielButton" showGoToAppStoreDialog:TRUE success:success error:error];
    }];
}

- (void)hasActiveSession:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult *result;
        LISDKSession *session = [[LISDKSessionManager sharedInstance] session];
        if(session != nil) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[session isValid]];
        } else {
            //Should never happen
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot verify if a preceding session is present"];
        }
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

    }];

}

- (void)getActiveSession:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate runInBackground:^{
        CDVPluginResult *result;
        LISDKSession *session = [[LISDKSessionManager sharedInstance] session];
        if (session != nil) {
            if ([session isValid] == TRUE) {
                NSDictionary* res = @{
                    @"accessToken": [session.accessToken accessTokenValue],
                    @"expiresOn": [NSNumber numberWithDouble:[[session.accessToken expiration] timeIntervalSince1970] * 1000]
                };
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:res];
            } else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:nil];
            }
        } else {
            //Should never happen
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Cannot verify if a preceding session is present"];
        }
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

@end
