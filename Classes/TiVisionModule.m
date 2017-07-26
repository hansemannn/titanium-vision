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
#import "TiVisionUtilities.h"

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

- (void)detectFaceRectangles:(id)args
{
#if IS_IOS_11
    ENSURE_SINGLE_ARG(args, NSDictionary);
    ENSURE_TYPE([args objectForKey:@"callback"], KrollCallback);
    
    id image = [args objectForKey:@"image"];
    id regionOfInterest = [args objectForKey:@"regionOfInterest"];
    UIImage *inputImage = nil;
    
    if ([image isKindOfClass:[NSString class]] || [image isKindOfClass:[TiBlob class]]) {
        inputImage = [TiUtils image:[args objectForKey:@"image"] proxy:self];
    } else {
        [self throwException:@"Invalid type provided" subreason:@"Please pass either a String or a Ti.Blob." location:CODELOCATION];
        return;
    }
    
    KrollCallback *callback = (KrollCallback *)[args objectForKey:@"callback"];
    NSError *requestHandlerError = nil;
    
    VNDetectFaceRectanglesRequest *request = [[VNDetectFaceRectanglesRequest alloc] initWithCompletionHandler:^(VNRequest *request, NSError *error) {
        if ([request results] == nil || [[request results] count] == 0) {
            [callback call:@[@{
                 @"success": NUMBOOL(NO),
                 @"error": [NSString stringWithFormat:@"%@ %@", @"Could not find any results.", [error localizedDescription]]
             }] thisObject:self];
            return;
        }
        
        NSMutableArray<NSDictionary<NSString *, id> *> *observations = [NSMutableArray arrayWithCapacity:[[request results] count]];
        
        for (VNFaceObservation *observation in (NSArray<VNFaceObservation *> *)[request results]) {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            
            [dictionary setObject:[TiVisionUtilities dictionaryFromBoundingBox:observation.boundingBox andImageWidth:inputImage.size.width]
                           forKey:@"boundingBox"];
            
            if ([observation landmarks] != nil) {
                [dictionary setObject:[TiVisionUtilities dictionaryFromLandmarks:[observation landmarks]] forKey:@"landmarks"];
            }
        }
        
        NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{
            @"success": NUMBOOL(YES),
            @"observations": observations
        }];
        
        [callback call:@[event] thisObject:self];
    }];
    
    if (regionOfInterest != nil) {
        request.regionOfInterest = [TiUtils rectValue:regionOfInterest];
    }
        
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

- (void)detectTextRectangles:(id)args
{
#if IS_IOS_11
    ENSURE_SINGLE_ARG(args, NSDictionary);
    ENSURE_TYPE([args objectForKey:@"callback"], KrollCallback);
    
    id image = [args objectForKey:@"image"];
    id regionOfInterest = [args objectForKey:@"regionOfInterest"];
    UIImage *inputImage = nil;
    
    if ([image isKindOfClass:[NSString class]] || [image isKindOfClass:[TiBlob class]]) {
        inputImage = [TiUtils image:[args objectForKey:@"image"] proxy:self];
    } else {
        [self throwException:@"Invalid type provided" subreason:@"Please pass either a String or a Ti.Blob." location:CODELOCATION];
        return;
    }
    
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
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
                  @"boundingBox": @{
                    @"x": @(CGRectGetMinX(observation.boundingBox)),
                    @"y": @(CGRectGetMinY(observation.boundingBox)),
                    @"width": @(CGRectGetWidth(observation.boundingBox)),
                    @"height": @(CGRectGetHeight(observation.boundingBox)),
                 }
            }];
            
            if ([observation characterBoxes] != nil) {
                NSMutableArray<NSDictionary<NSString *, id> *> *characterBoxes = [NSMutableArray arrayWithCapacity:[[observation characterBoxes] count]];
                
                for (VNRectangleObservation *box in [observation characterBoxes]) {
                    [characterBoxes addObject:[TiVisionUtilities dictionaryFromRectangle:box]];
                }
                
                [dictionary setObject:characterBoxes forKey:@"characterBoxes"];
            }
            [observations addObject:dictionary];
        }
        
        
        
        NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{
            @"success": NUMBOOL(YES),
            @"observations": observations
        }];
        
        [callback call:@[event] thisObject:self];
    }];
    
    request.reportCharacterBoxes = reportCharacterBoxes;
    
    if (regionOfInterest != nil) {
        request.regionOfInterest = [TiUtils rectValue:regionOfInterest];
    }

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
