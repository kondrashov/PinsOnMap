//
//  UIImage+Additions.h
//  TestTask
//
//  Created by Artem on 19.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)

- (UIImage*)safeResizableImageWithCapInsets:(UIEdgeInsets)edgeInsets
                               resizingMode:(UIImageResizingMode)resizingMode;

- (UIImage *)imageWithLimitedSize;
- (UIImage *)scaledImageForSize:(CGSize)maxSize;


@end
