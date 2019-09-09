//
//  TiVisionUtilities.h
//  titanium-vision
//
//  Created by Hans Knöchel on 06.07.17.
//

#import <Foundation/Foundation.h>
#import <Vision/Vision.h>

@interface TiVisionUtilities : NSObject

+ (NSDictionary<NSString *, id> *)dictionaryFromBoundingBox:(CGRect)boundingBox andImageWidth:(CGFloat)imageWidth;

+ (NSDictionary<NSString *, id> *)dictionaryFromLandmarks:(VNFaceLandmarks2D *)landmarks;

+ (NSDictionary<NSString *, id> *)dictionaryFromRectangle:(VNRectangleObservation* )rectangle;

+ (NSArray<NSNumber *> *)arrayFromLandmarkRegion:(VNFaceLandmarkRegion2D *)landmarkRegion;

@end
