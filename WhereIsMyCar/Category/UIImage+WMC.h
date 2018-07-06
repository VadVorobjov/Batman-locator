//
//  UIImage+WMC.h
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 01/07/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (WMC)

#pragma mark - Networking

+ (void)downloadImageFromURL:(NSString *)imageURL completionBlock:(void (^)(BOOL success, UIImage *image))completion;

@end
