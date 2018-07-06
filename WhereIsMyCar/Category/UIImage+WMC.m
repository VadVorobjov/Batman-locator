//
//  UIImage+WMC.m
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 01/07/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import "UIImage+WMC.h"

@implementation UIImage (WMC)

#pragma mark - Networking

+ (void)downloadImageFromURL:(NSString *)imageURL completionBlock:(void (^)(BOOL, UIImage *))completion{
    NSURL *url = [NSURL URLWithString:imageURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                               if (!connectionError) {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completion(YES, image);
                               } else {
                                   NSLog(@"- (void)downloadImageFromURL: error on downloading image data from URL: %@", connectionError.localizedDescription);
                                   completion(NO, nil);
                               }
                           }];
}

+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
