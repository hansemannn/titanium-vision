/**
 * titanium-vision
 *
 * Created by Hans Knoechel
 * Copyright (c) 2017 Your Company. All rights reserved.
 */

#if IS_IOS_11
#import <Vision/Vision.h>
#endif

#import "TiVisionModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation TiVisionModule

#pragma mark Internal

- (id)moduleGUID
{
	return @"f39ef2bb-26ef-409b-aad4-c9e70b1016b5";
}

- (NSString *)moduleId
{
	return @"ti.vision";
}

#pragma mark Lifecycle

-(void)startup
{
	[super startup];
	NSLog(@"[DEBUG] %@ loaded",self);
}

#pragma Public APIs

- (id)isSupported:(id)unused
{
    return NUMBOOL([TiUtils isIOSVersionOrGreater:@"11.0"]);
}

- (void)detectTextRectangles:(id)args
{
#if IS_IOS_11
    ENSURE_SINGLE_ARG(args, NSDictionary);
    ENSURE_TYPE([args objectForKey:@"image"], NSString);
    ENSURE_TYPE([args objectForKey:@"callback"], KrollCallback);
    
    UIImage *inputImage = [TiUtils image:[args objectForKey:@"image"] proxy:self];
    KrollCallback *callback = (KrollCallback *)[args objectForKey:@"callback"];
    BOOL reportCharacterBoxes = [TiUtils boolValue:@"reportCharacterBoxes" properties:args def:NO];
    
    NSError *requestHandlerError = nil;
    
    VNDetectTextRectanglesRequest *request = [[VNDetectTextRectanglesRequest alloc] initWithCompletionHandler:^(VNRequest *request, NSError *error) {
        if ([request results] == nil || [[request results] count] == 0) {
            [callback call:@[@{
                @"success": NUMBOOL(NO),
                @"error": [NSString stringWithFormat:@"%@ %@", @"Could not find any results.", [error localizedDescription]]
            }] thisObject:self];
            return;
        }
        
        NSMutableArray<NSDictionary<NSString *, id> *> *observations = [NSMutableArray arrayWithCapacity:[[request results] count]];
        
        for (VNTextObservation *observation in (NSArray<VNTextObservation *> *)[request results]) {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            
            [dictionary setObject:@{
                @"x": NUMFLOAT(observation.boundingBox.origin.x * inputImage.size.width),
                @"y": NUMFLOAT(observation.boundingBox.origin.y * inputImage.size.width),
                @"width": NUMFLOAT(observation.boundingBox.size.width * inputImage.size.width),
                @"height": NUMFLOAT(observation.boundingBox.size.height * inputImage.size.width),
            } forKey:@"boundingBox"];
            
            if ([observation characterBoxes] != nil) {
                NSMutableArray<NSDictionary<NSString *, id> *> *characterBoxes = [NSMutableArray arrayWithCapacity:[[observation characterBoxes] count]];
                
                for (VNRectangleObservation *box in [observation characterBoxes]) {
                    [characterBoxes addObject:@{
                        @"topLeft": @{@"x": NUMFLOAT(box.topLeft.x), @"y": NUMFLOAT(box.topLeft.y)},
                        @"topRight": @{@"x": NUMFLOAT(box.topRight.x), @"y": NUMFLOAT(box.topRight.y)},
                        @"bottomLeft": @{@"x": NUMFLOAT(box.bottomLeft.x), @"y": NUMFLOAT(box.bottomLeft.y)},
                        @"bottomRight": @{@"x": NUMFLOAT(box.bottomRight.x), @"y": NUMFLOAT(box.bottomRight.y)}
                    }];
                }
                
                [dictionary setObject:characterBoxes forKey:@"characterBoxes"];
            }
        }
        
        NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{
            @"success": NUMBOOL(YES),
            @"observations": observations
        }];
        
        [callback call:@[event] thisObject:self];
    }];
    
    request.reportCharacterBoxes = reportCharacterBoxes;
    
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:inputImage.CGImage options:@{}];
    [handler performRequests:@[request] error:&requestHandlerError];
    
    if (requestHandlerError != nil) {
        [callback call:@[@{
            @"success": NUMBOOL(NO),
            @"error": [requestHandlerError localizedDescription]
        }] thisObject:self];
    }
#else
    [callback call:@[@{
        @"success": NUMBOOL(NO),
        @"error": @"This API is iOS 11+ only, please guard using the \"isSupported()\" method and try again."
    }] thisObject:self];
#endif
}

@end
