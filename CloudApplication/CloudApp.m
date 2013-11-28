#import "CloudApp.h"

#import <OCFoundation/OCFoundation.h>

@implementation CloudApp
+ (void)finishLaunching {
  [self handleRequestsWithMethod:@"GET" matchingPath:@"/" withBlock:^(OCFRequest *request) {
    NSString *appName = [[NSBundle mainBundle] infoDictionary][@"OCFCloudAppName"];
    NSMutableString *result = [NSMutableString new];
    
    [result appendString:@"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">"];
    [result appendString:@"<html><head>"];
    [result appendString:@"<style type=\"text/css\">body {font-family: \"HelveticaNeue-Light\", \"Helvetica Neue Light\", \"Helvetica Neue\", Helvetica, Arial, \"Lucida Grande\", sans-serif;} pre { background-color:#efefef; padding:10px;  overflow: auto; word-wrap: normal; white-space: pre; }</style>"];
    [result appendFormat:@"<title>%@</title>", appName];
    [result appendString:@"</head><body>"];
    [result appendString:@"<h1>Congratulations!</h1>"];
    [result appendString:@"<p>You did it! Your cloud application is running! You can now invoke methods by using Terminal (or any other HTTP client). Give it a try.</p>"];
    [result appendString:@"<h2>On localhost</h2>"];
    [result appendFormat:@"<pre>curl -X POST localhost:10000/Service -d '{\"selector\" : \"sayHello\", \"arguments\" : []}'</pre>"];
    [result appendString:@"<h2>On Objective-Cloud</h2>"];
    [result appendFormat:@"<pre>curl -X POST https://%@.obcl.io/Service -d '{\"selector\" : \"sayHello\", \"arguments\" : []}'</pre>", appName];
    [result appendString:@"</body></html>"];

    [request respondWith:result];
  }];
}
@end
