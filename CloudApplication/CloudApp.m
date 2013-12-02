#import "CloudApp.h"

#import <OCFoundation/OCFoundation.h>
#import <OCFWeb/OCFRequest.h>

@implementation CloudApp

+ (void)finishLaunching {
    // Add the route and handler
    [self handleRequestsWithMethod:@"GET"
                      matchingPath:@"/hello"
                         withBlock:^(OCFRequest *request) {
                             // respond with "Hello World"
                             [request respondWith:@"Hello World"];
                         }];
    
    [self handleRequestsWithMethod:@"GET" matchingPath:@"/" withBlock:^(OCFRequest *request) {
        NSMutableString *result = [NSMutableString new];
        
        [result appendString:@"<form method=\"post\" enctype=\"multipart/form-data\">"];
        [result appendString:@"File name:<input type=\"file\" name=\"imgfile\"><br>"];
        [result appendString:@"<input type=\"submit\" name=\"submit\" value=\"upload\">"];
        [result appendString:@"</form>"];
        [request respondWith:result];
    }];
    
    [self handleRequestsWithMethod:@"POST" matchingPath:@"/" withBlock:^(OCFRequest *request) {
        [request respondWith:[request.parameters description]];
    }];
}

@end





