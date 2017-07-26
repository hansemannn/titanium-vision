//
//  TiVisionUtilities.m
//  titanium-vision
//
//  Created by Hans Knöchel on 06.07.17.
//

#if IS_IOS_11

#import "TiVisionUtilities.h"
#import "TiBase.h"
#import "TiHost.h"

@implementation TiVisionUtilities

+ (NSDictionary<NSString*, id> *)dictionaryFromBoundingBox:(CGRect)boundingBox andImageWidth:(CGFloat)imageWidth
{
    return @{
        @"x": NUMFLOAT(boundingBox.origin.x * imageWidth),
        @"y": NUMFLOAT(boundingBox.origin.y * imageWidth),
        @"width": NUMFLOAT(boundingBox.size.width * imageWidth),
        @"height": NUMFLOAT(boundingBox.size.height * imageWidth),
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
        @"topLeft": @{@"x": NUMFLOAT(rectangle.topLeft.x), @"y": NUMFLOAT(rectangle.topLeft.y)},
        @"topRight": @{@"x": NUMFLOAT(rectangle.topRight.x), @"y": NUMFLOAT(rectangle.topRight.y)},
        @"bottomLeft": @{@"x": NUMFLOAT(rectangle.bottomLeft.x), @"y": NUMFLOAT(rectangle.bottomLeft.y)},
        @"bottomRight": @{@"x": NUMFLOAT(rectangle.bottomRight.x), @"y": NUMFLOAT(rectangle.bottomRight.y)}
    };
}

+ (NSArray<NSDictionary<NSString *,  NSNumber*> *> *)arrayFromLandmarkRegion:(VNFaceLandmarkRegion2D *)landmarkRegion
{
    NSMutableArray<NSDictionary<NSString *,  NSNumber*> *> *points = [NSMutableArray arrayWithCapacity:sizeof(landmarkRegion.points)];
    
    for (int i = 0; i < sizeof(landmarkRegion.points); i++) {
        [points addObject:@{
            @"x": NUMFLOAT(landmarkRegion.points[i].x),
            @"y": NUMFLOAT(landmarkRegion.points[i].y)
        }];
    }
         
    return points;
}

@end

#endif
