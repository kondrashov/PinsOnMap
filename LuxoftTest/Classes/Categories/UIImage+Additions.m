//
//  UIImage+Additions.m
//  TestTask
//
//  Created by Artem on 19.04.15.
//  Copyright (c) 2015 ArtemK. All rights reserved.
//

#import "UIImage+Additions.h"

@implementation UIImage (Additions)

- (UIImage*)safeResizableImageWithCapInsets:(UIEdgeInsets)edgeInsets
                               resizingMode:(UIImageResizingMode)resizingMode
{
    if ([UIImage resolveInstanceMethod:@selector(resizableImageWithCapInsets:)])
        return [self resizableImageWithCapInsets:edgeInsets resizingMode:UIImageResizingModeStretch];
    else
        return [self stretchableImageWithLeftCapWidth:edgeInsets.left topCapHeight:edgeInsets.top];
    
    return nil;
}

- (UIImage *)imageWithLimitedSize
{
    static CGSize sMaxSize = {1024, 1024};
    
    CGSize newSize = CGSizeMake(MIN(sMaxSize.width, self.size.width), MIN(sMaxSize.height, self.size.height));
    UIImage *result = [self scaledImageForSize:newSize];
    
    return result;
}

- (UIImage *)scaledImageForSize:(CGSize)maxSize
{
    CGSize sizeOfImage = [self size];
    
    if (CGSizeEqualToSize(maxSize, sizeOfImage))
        return self;
    
    CGSize targetSize;
    
    if(maxSize.width / sizeOfImage.width < maxSize.height / sizeOfImage.height)
    {
        targetSize.width = maxSize.width;
        
        targetSize.height =
        (maxSize.width / sizeOfImage.width) * sizeOfImage.height;
    }
    else
    {
        targetSize.height = maxSize.height;
        targetSize.width =
        (maxSize.height / sizeOfImage.height) * sizeOfImage.width;
    }
    
    CGRect targetRect;
    
    targetRect.size = targetSize;
    targetSize.width = ceilf(targetSize.width);
    targetSize.height = ceilf(targetSize.height);
    
    targetRect.origin.x = (targetSize.width - targetRect.size.width) * 0.5f;
    targetRect.origin.y = (targetSize.height - targetRect.size.height) * 0.5f;
    
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 1);
    [self drawInRect:targetRect];
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return returnImage;
}

@end
