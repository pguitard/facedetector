#import "CloudApp.h"

#import <OCFoundation/OCFoundation.h>
#import <OCFWeb/OCFRequest.h>
#import <QuartzCore/QuartzCore.h>

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
        NSDictionary *parameters = request.parameters;
        NSDictionary *imgfile = parameters[@"imgfile"];
        NSString *temporaryPath = imgfile[@"temporaryPath"];
        
        NSData *imageData = [NSData dataWithContentsOfFile:temporaryPath];
        
        NSArray *facesFeatures = [self imageProcessing:imageData];
 
        NSMutableString *result = [NSMutableString new];

        [result appendString:[NSString stringWithFormat:@"Found %lu face(s)!<br>", (unsigned long)[facesFeatures count]]];

        NSInteger smilingFaces = 0;
        
        for (CIFaceFeature *f in facesFeatures) {
            if ([f hasSmile]) {
                smilingFaces++;
            }
        }
        
        [result appendString:[NSString stringWithFormat:@"%ld face(s) smiling!", (long)smilingFaces]];
        
        [request respondWith:result];
    }];
}

+ (NSArray *)imageProcessing:(NSData *)data {
    CIContext *context = [CIContext contextWithCGContext:[[NSGraphicsContext currentContext] graphicsPort] options:nil];
    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:context
                                              options:opts];
    
    CIImage *image = [CIImage imageWithData:data];
    NSArray *features = [detector featuresInImage:image options:nil];
    
    return features;
}

@end





