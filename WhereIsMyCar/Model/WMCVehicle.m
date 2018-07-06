//
//  WMCVehicle.m
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 01/07/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import "WMCVehicle.h"

@implementation WMCVehicle

#pragma mark - Initializers

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _identifier = @"";
        _photo = nil;
        _make = @"";
        _model = @"";
        _color = nil;
        _vin = @"";
        _year = @"";
    }
    
    return self;
}

@end
