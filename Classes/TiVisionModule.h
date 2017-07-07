/**
 * titanium-vision
 *
 * Created by Hans Knoechel
 * Copyright (c) 2017 Your Company. All rights reserved.
 */

#import "TiModule.h"

@interface TiVisionModule : TiModule

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

@end
