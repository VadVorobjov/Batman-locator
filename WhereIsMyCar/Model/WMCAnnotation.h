//
//  WMCAnnotation.h
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 04/07/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface WMCAnnotation : NSObject <MKAnnotation>

#pragma mark - Properties

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSString *subtitle;

#pragma mark - Initializers

- (instancetype)initWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
                        color:(UIColor *)color
                        image:(UIImage *)image
                andCoordinate:(CLLocationCoordinate2D)coordinate;

#pragma mark - Methos

- (MKMapItem *)mapItem;

@end
