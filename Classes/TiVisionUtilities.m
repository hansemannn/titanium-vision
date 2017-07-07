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
        @"allPoints": [TiVisionUtilities arrayFromLandmarkRegion:landmarks.allPoints]
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

+ (NSArray<NSNumber *> *)arrayFromLandmarkRegion:(VNFaceLandmarkRegion2D *)landmarkRegion
{
    NSMutableArray<NSNumber *> *points = [NSMutableArray arrayWithCapacity:sizeof(landmarkRegion.points)];
    
//    for (int i = 0; i < sizeof(landmarkRegion.points); i++) {
//        [points addObject:[NSNumber numberWithFloat:landmarkRegion.points[i]];
//    }
    
    return points;
}

@end

#endif
