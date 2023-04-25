/**
 * titanium-vision
 *
 * Created by Hans Knoechel
 * Copyright (c) 2017 Your Company. All rights reserved.
 */

#import <Vision/Vision.h>
#import <VisionKit/VisionKit.h>

#import "TiVisionModule.h"
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

- (void)_configure
{
  [super _configure];

  dispatch_queue_attr_t qosAttribute = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_UTILITY, 0);
  textRecognitionQueue = dispatch_queue_create("ti.vision.queue", qosAttribute);
}

- (void)_destroy
{
  [super _destroy];

  textRecognitionQueue = nil;
}

#pragma Public APIs

- (NSNumber *)isSupported:(id)unused
{
    return @([TiUtils isIOSVersionOrGreater:@"11.0"]);
}

- (void)recognizeText:(id)args
{
  ENSURE_SINGLE_ARG(args, NSDictionary);

  __block UIImage *image = [TiUtils toImage:args[@"image"] proxy:self];
  KrollCallback *callback = (KrollCallback *)args[@"callback"];

  NSArray<NSString *> *customWords = args[@"customWords"];
  NSArray<NSString *> *recognitionLanguages = args[@"recognitionLanguages"];
  BOOL usesLanguageCorrection = [TiUtils boolValue:@"usesLanguageCorrection" properties:args def:YES];

  if (image == nil || callback == nil) {
    [self throwException:@"Missing image or callback" subreason:@"The image or callback is missing" location:CODELOCATION];
  }

  VNRecognizeTextRequest *textRecognitionRequest = [[VNRecognizeTextRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
    NSArray<VNRecognizedTextObservation *> *observations = request.results;
    NSMutableArray<NSString *> *results = [NSMutableArray arrayWithCapacity:observations.count];

    [observations enumerateObjectsUsingBlock:^(VNRecognizedTextObservation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
      VNRecognizedText *topCandidate = [obj topCandidates:1].firstObject;
      [results addObject:topCandidate.string];
    }];

    [callback call:@[@{ @"success": @YES, @"results": results }] thisObject:self];
  }];

  textRecognitionRequest.usesLanguageCorrection = usesLanguageCorrection;

  if (customWords != nil) {
    textRecognitionRequest.customWords = customWords;
  }

  if (recognitionLanguages != nil) {
    textRecognitionRequest.recognitionLanguages = recognitionLanguages;
  }

  dispatch_async(textRecognitionQueue, ^{
    VNImageRequestHandler *requesHandler = [[VNImageRequestHandler alloc] initWithCGImage:image.CGImage options:@{}];
    NSError *error = nil;
  
    [requesHandler performRequests:@[textRecognitionRequest] error:&error];
    
    if (error != nil) {
      [callback call:@[@{ @"success": @NO, @"error": error.localizedDescription }] thisObject:self];
    }
  });
}

- (void)detectFaceRectangles:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    ENSURE_TYPE([args objectForKey:@"callback"], KrollCallback);
    
    id image = [args objectForKey:@"image"];
    id regionOfInterest = [args objectForKey:@"regionOfInterest"];
    KrollCallback *callback = (KrollCallback *)[args objectForKey:@"callback"];
    UIImage *inputImage = nil;
    NSError *requestHandlerError = nil;

    if ([image isKindOfClass:[NSString class]] || [image isKindOfClass:[TiBlob class]]) {
        inputImage = [TiUtils image:[args objectForKey:@"image"] proxy:self];
    } else {
        [self throwException:@"Invalid type provided" subreason:@"Please pass either a String or a Ti.Blob." location:CODELOCATION];
        return;
    }
    
    VNDetectFaceRectanglesRequest *request = [[VNDetectFaceRectanglesRequest alloc] initWithCompletionHandler:^(VNRequest *request, NSError *error) {
        if ([request results] == nil || [[request results] count] == 0) {
            [callback call:@[@{
                 @"success": @(NO),
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
            @"success": @(YES),
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
            @"success": @(NO),
            @"error": [requestHandlerError localizedDescription]
        }] thisObject:self];
    }
}

- (void)detectTextRectangles:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    ENSURE_TYPE([args objectForKey:@"callback"], KrollCallback);
    
    id image = [args objectForKey:@"image"];
    id regionOfInterest = [args objectForKey:@"regionOfInterest"];
    UIImage *inputImage = nil;
    KrollCallback *callback = (KrollCallback *)[args objectForKey:@"callback"];
    NSError *requestHandlerError = nil;
    BOOL reportCharacterBoxes = [TiUtils boolValue:@"reportCharacterBoxes" properties:args def:NO];
    
    if ([image isKindOfClass:[NSString class]] || [image isKindOfClass:[TiBlob class]]) {
        inputImage = [TiUtils image:[args objectForKey:@"image"] proxy:self];
    } else {
        [self throwException:@"Invalid type provided" subreason:@"Please pass either a String or a Ti.Blob." location:CODELOCATION];
        return;
    }
    
    VNDetectTextRectanglesRequest *request = [[VNDetectTextRectanglesRequest alloc] initWithCompletionHandler:^(VNRequest *request, NSError *error) {
        if ([request results] == nil || [[request results] count] == 0) {
            [callback call:@[@{
                @"success": @(NO),
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
            @"success": @(YES),
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
            @"success": @(NO),
            @"error": [requestHandlerError localizedDescription]
        }] thisObject:self];
    }
}

- (void)detectRectangles:(id)args
{
    ENSURE_SINGLE_ARG(args, NSDictionary);
    ENSURE_TYPE([args objectForKey:@"callback"], KrollCallback);

    id image = [args objectForKey:@"image"];
    KrollCallback *callback = (KrollCallback *)[args objectForKey:@"callback"];
    UIImage *inputImage = nil;
    NSError *requestHandlerError = nil;

    if ([image isKindOfClass:[NSString class]] || [image isKindOfClass:[TiBlob class]]) {
        inputImage = [TiUtils image:[args objectForKey:@"image"] proxy:self];
    } else {
        [self throwException:@"Invalid type provided" subreason:@"Please pass either a String or a Ti.Blob." location:CODELOCATION];
        return;
    }

    VNDetectRectanglesRequest *request = [[VNDetectRectanglesRequest alloc] initWithCompletionHandler:^(VNRequest *request, NSError *error) {
        if ([request results] == nil || [[request results] count] == 0) {
            [callback call:@[@{
                @"success": @(NO),
                @"error": [NSString stringWithFormat:@"%@ %@", @"Could not find any results.", [error localizedDescription]]
            }] thisObject:self];
            return;
        }

        NSMutableArray<NSDictionary<NSString *, id> *> *observations = [NSMutableArray arrayWithCapacity:[[request results] count]];

        for (VNRectangleObservation *observation in (NSArray<VNRectangleObservation *> *)[request results]) {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

            [dictionary setObject:[TiVisionUtilities dictionaryFromRectangle:observation] forKey:@"rectangle"];
            [observations addObject:dictionary];
        }

        NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:@{
            @"success": @(YES),
            @"observations": observations
        }];

        [callback call:@[event] thisObject:self];
    }];

    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:inputImage.CGImage options:@{}];
    [handler performRequests:@[request] error:&requestHandlerError];

    if (requestHandlerError != nil) {
        [callback call:@[@{
            @"success": @(NO),
            @"error": [requestHandlerError localizedDescription]
        }] thisObject:self];
    }
}

@end
