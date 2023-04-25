/**
 * titanium-vision
 *
 * Created by Hans Knoechel
 * Copyright (c) 2017 Your Company. All rights reserved.
 */

#import <TitaniumKit/TitaniumKit.h>

@interface TiVisionModule : TiModule {
  @private
  dispatch_queue_t textRecognitionQueue;
}

/**
 * A request that will detect faces in an image.
 *
 * @since 1.1.0
 * @args The arguments passed to the face-detection.
 */
- (void)detectFaceRectangles:(id)args;

/**
 * A request that will detect regions of text in an image.
 *
 * @since 1.1.0
 * @args The arguments passed to the text-detection.
 */
- (void)detectTextRectangles:(id)args;

/**
 * A request that will rectangles regions in an image.
 *
 * @since 2.1.0
 * @args The arguments passed to the text-detection.
 */
- (void)detectRectangles:(id)args;

/**
 * Returns a rectangle in (possibly non-integral) image coordinates that is projected from a rectangle in a normalized coordinate space.
 *
 * @since 2.1.0
 * @args The arguments passed to the util (rect, width and height)
 */
- (NSDictionary *)imageRectForNormalizedRect:(id)args;

@end
