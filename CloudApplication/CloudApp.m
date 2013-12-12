#import "CloudApp.h"

#import <OCFoundation/OCFoundation.h>
#import <OCFWeb/OCFRequest.h>
#import <QuartzCore/QuartzCore.h>
#import "NSData+Base64.h"

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
        
        [result appendString:@"     <form role=\"form\" method=\"post\" enctype=\"multipart/form-data\">"];
        [result appendString:@"         <div class=\"form-group\">"];
        [result appendString:@"             <label for=\"imgfile\">File input</label>"];
        [result appendString:@"             <input type=\"file\" name=\"imgfile\"><p class=\"help-block\">Please select a picture showing people.</p>"];
        [result appendString:@"             <div class=\"pull-right\"><button type=\"submit\" class=\"btn btn-primary\" name=\"submit\">Upload</button></div>"];
        [result appendString:@"         </div>"];
        [result appendString:@"     </form>"];
        
        [request respondWith:[self generateResponse:result]];
    }];
    
    [self handleRequestsWithMethod:@"POST" matchingPath:@"/" withBlock:^(OCFRequest *request) {
        NSDictionary *parameters = request.parameters;
        
        NSDictionary *imgfile = parameters[@"imgfile"];

        if (!imgfile) {
            NSMutableString *result = [NSMutableString new];

            [result appendString:@"<div class=\"alert alert-danger\">No picture to process!</div>"];
            [result appendString:@"<div class=\"row\"><div class=\"col-xs-12\"><div class=\"pull-right\"><form method=\"get\"><input type=\"submit\" class=\"btn btn-primary\" value=\"Try again\"></input></form></div></div></div>"];
            
            [request respondWith:[self generateResponse:result]];
        } else {
            NSString *temporaryPath = imgfile[@"temporaryPath"];
            
            NSData *imageData = [NSData dataWithContentsOfFile:temporaryPath];
            CIImage *image = [CIImage imageWithData:imageData];
            
            NSArray *facesFeatures = [self imageProcessing:image];
     
            NSMutableString *result = [NSMutableString new];

            NSInteger index = 0;
            
            [result appendString:@"<div class=\"row\">"];
                                   
            for (CIFaceFeature *f in facesFeatures) {
                index++;
                CIImage *croppedImage = [image imageByCroppingToRect:[f bounds]];
                NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithCIImage:croppedImage];
                NSData *croppedImageData = [imageRep representationUsingType:NSPNGFileType properties:nil];
                NSString *htmlImage = [NSString stringWithFormat:@"<div class=\"col-xs-%lu\"><img class=\"thumbnail\" width=\"100\" height=\"100\" src=\"data:image/png;base64,%@\"/></div>", 12 / [facesFeatures count], [croppedImageData base64EncodedString]];
                [result appendString:htmlImage];
            }
            
            [result appendString:@"</div>"];

            [result appendString:@"<div class=\"row\"><div class=\"col-xs-12\"><form method=\"get\"><div class=\"pull-right\"><input type=\"submit\" class=\"btn btn-primary\" value=\"Home\"></input></form></div></div></div>"];

            [request respondWith:[self generateResponse:result]];
        }
    }];
}

+ (NSString *)generateResponse:(NSString *)response {
    NSMutableString *result = [NSMutableString new];
    
    [result appendString:@"<!DOCTYPE html>"];
    
    [result appendString:@"<html lang=\"en\">"];
    
    [result appendString:@" <head>"];
    [result appendString:@"     <title>Face Detector</title>"];
    [result appendString:@"     <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">"];
    [result appendString:@"     <link rel=\"stylesheet\" href=\"//netdna.bootstrapcdn.com/bootstrap/3.0.2/css/bootstrap.min.css\">"];
    [result appendString:@" </head>"];
    
    [result appendString:@" <body>"];
    [result appendString:@"     <script src=\"https://code.jquery.com/jquery.js\"></script>"];
    [result appendString:@"     <script src=\"//netdna.bootstrapcdn.com/bootstrap/3.0.2/js/bootstrap.min.js\"></script>"];
    [result appendString:@"     <br>"];

    [result appendString:@"     <div class=\"row\">"];
    [result appendString:@"         <div class=\"col-xs-1\"></div>"];
    [result appendString:@"         <div class=\"col-xs-10\">"];
    
    [result appendString:@"             <div class=\"panel panel-primary\">"];
    [result appendString:@"                 <div class=\"panel-heading\">"];
    [result appendString:@"                     <h1 class=\"panel-title\">Face Detector</h1>"];
    [result appendString:@"                 </div>"];
    [result appendString:@"                 <div class=\"panel-body\">"];
    
    [result appendString:response];
    
    [result appendString:@"                 </div>"];
    [result appendString:@"             </div>"];
    [result appendString:@"         </div>"];
    [result appendString:@"         <div class=\"col-xs-1\"></div>"];
    [result appendString:@"     </div>"];
    [result appendString:@" </body>"];
    
    [result appendString:@"</html>"];
    
    return result;
}

+ (NSArray *)imageProcessing:(CIImage *)image {
    CIContext *context = [CIContext contextWithCGContext:[[NSGraphicsContext currentContext] graphicsPort] options:nil];
    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:context
                                              options:opts];
    
    NSArray *features = [detector featuresInImage:image options:nil];
    
    return features;
}

@end
