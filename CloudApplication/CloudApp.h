// This file contains a protocol specification (CloudAppPublishing) and a class interface (CloudApp).
// You can specify class methods in the CloudAppPublishing protocol and implement those methods
// in your CloudApp implementation. This was you can execute code that run in the context of your
// cloud application. In contrast, messages sent to your service are executed in the environment of
// an XPC service. Putting code in the cloud application class in considered an advanced topic.
// Do this only if you know what you are doing. Please consult the documentation for advanced topics for
// more information.
//
// Documentation for advanced topics: 
// https://github.com/Objective-Cloud/docs/wiki/Advanced-Topics


#import <OCFoundation/OCFCloudApp.h>

@interface CloudApp : OCFCloudApp
@end
