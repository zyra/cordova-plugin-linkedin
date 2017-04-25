@interface LinkedIn : CDVPlugin
- (void) login: (CDVInvokedUrlCommand *) command;
- (void) logout: (CDVInvokedUrlCommand *) command;
- (void) getRequest: (CDVInvokedUrlCommand *) command;
- (void) postRequest: (CDVInvokedUrlCommand *) command;
- (void) openProfile: (CDVInvokedUrlCommand *) command;
- (void) hasActiveSession: (CDVInvokedUrlCommand *) command;
- (void) getActiveSession: (CDVInvokedUrlCommand *) command;
@end
