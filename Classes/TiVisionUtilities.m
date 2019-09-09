//
//  TiVisionUtilities.m
//  titanium-vision
//
//  Created by Hans Knöchel on 06.07.17.
//

#import "TiVisionUtilities.h"

@implementation TiVisionUtilities

+ (NSDictionary<NSString*, id> *)dictionaryFromBoundingBox:(CGRect)boundingBox andImageWidth:(CGFloat)imageWidth
{
    return @{
        @"x": @(boundingBox.origin.x * imageWidth),
        @"y": @(boundingBox.origin.y * imageWidth),
        @"width": @(boundingBox.size.width * imageWidth),
        @"height": @(boundingBox.size.height * imageWidth),
    };
}

+ (NSDictionary<NSString *, id> *)dictionaryFromLandmarks:(VNFaceLandmarks2D* )landmarks
{
    return @{
        @"allPoints": [TiVisionUtilities arrayFromLandmarkRegion:landmarks.allPoints],
        @"faceContour": [TiVisionUtilities arrayFromLandmarkRegion:landmarks.faceContour],
        @"leftEye": [TiVisionUtilities arrayFromLandmarkRegion:landmarks.leftEye],
        @"rightEye": [TiVisionUtilities arrayFromLandmarkRegion:landmarks.rightEye],
        @"leftPupil": [TiVisionUtilities arrayFromLandmarkRegion:landmarks.leftPupil],
        @"rightPupil": [TiVisionUtilities arrayFromLandmarkRegion:landmarks.rightPupil],
        @"leftEyebrow": [TiVisionUtilities arrayFromLandmarkRegion:landmarks.leftEyebrow],
        @"rightEyebrow": [TiVisionUtilities arrayFromLandmarkRegion:landmarks.rightEyebrow],
        @"nose": [TiVisionUtilities arrayFromLandmarkRegion:landmarks.nose],
        @"noseCrest": [TiVisionUtilities arrayFromLandmarkRegion:landmarks.noseCrest],
        @"medianLine": [TiVisionUtilities arrayFromLandmarkRegion:landmarks.medianLine],
        @"outerLips": [TiVisionUtilities arrayFromLandmarkRegion:landmarks.outerLips],
        @"innerLips": [TiVisionUtilities arrayFromLandmarkRegion:landmarks.innerLips]
    };
}

+ (NSDictionary<NSString *, id> *)dictionaryFromRectangle:(VNRectangleObservation* )rectangle
{
    return @{
        @"topLeft": @{@"x": @(rectangle.topLeft.x), @"y": @(rectangle.topLeft.y)},
        @"topRight": @{@"x": @(rectangle.topRight.x), @"y": @(rectangle.topRight.y)},
        @"bottomLeft": @{@"x": @(rectangle.bottomLeft.x), @"y": @(rectangle.bottomLeft.y)},
        @"bottomRight": @{@"x": @(rectangle.bottomRight.x), @"y": @(rectangle.bottomRight.y)}
    };
}

+ (NSArray<NSDictionary<NSString *,  NSNumber*> *> *)arrayFromLandmarkRegion:(VNFaceLandmarkRegion2D *)landmarkRegion
{
    NSMutableArray<NSDictionary<NSString *,  NSNumber*> *> *points = [NSMutableArray arrayWithCapacity:sizeof(landmarkRegion.normalizedPoints)];
    
    for (int i = 0; i < sizeof(landmarkRegion.normalizedPoints); i++) {
        [points addObject:@{
            @"x": @(landmarkRegion.normalizedPoints[i].x),
            @"y": @(landmarkRegion.normalizedPoints[i].y)
        }];
    }
         
    return points;
}

@end
