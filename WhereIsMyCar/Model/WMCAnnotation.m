//
//  WMCAnnotation.m
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 04/07/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import "WMCAnnotation.h"
#import <Contacts/Contacts.h>

@interface WMCAnnotation()

#pragma mark - Properties

@property (nonatomic, strong) NSString *title;
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

@implementation WMCAnnotation

#pragma mark - Initializer

- (instancetype)initWithTitle:(NSString *)title
                     subtitle:(NSString *)subtitle
                        color:(UIColor *)color
                        image:(UIImage *)image
                andCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    
    if (self) {
        _title = title;
        _subtitle = subtitle;
        _color = color;
        _image = image;
        _coordinate = coordinate;
    }
    
    return self;
}

#pragma mark - Methods

- (MKMapItem *)mapItem
{
    MKPlacemark *placeMark;
    
    if (@available(iOS 9.0, *)) {
        NSDictionary *adressDict = @{ CNPostalAddressStreetKey : self.subtitle };
        placeMark = [[MKPlacemark alloc] initWithCoordinate:self.coordinate addressDictionary:adressDict];
    } else {
        // Fallback on earlier versions
        placeMark = [[MKPlacemark alloc] init];
        placeMark.coordinate = self.coordinate;
    }
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placeMark];
    
    return mapItem;
}

@end
