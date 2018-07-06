//
//  WMCUser.m
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 30/06/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import "WMCUser.h"

@implementation WMCUser

#pragma mark - Properties

- (NSMutableArray <WMCVehicle *> *)vehicle
{
    if (_vehicle == nil) {
        _vehicle = [[NSMutableArray alloc] init];
    }
    
    return _vehicle;
}

#pragma mark - Initializer

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _identifier = @"";
        _name = @"";
        _surname = @"";
        _photo = nil;
        _vehicle = nil;
    }
    
    return self;
}

#pragma mark - Methods

- (NSString *)receiveVehiclesMakesSeparetedBy:(NSString *)separator
{
    NSMutableArray *vehiclesMakes = [[NSMutableArray alloc] init];
    
    for (WMCVehicle *vehicle in self.vehicle) {
        [vehiclesMakes addObject:vehicle.make];
    }
    
    return [vehiclesMakes componentsJoinedByString:separator];
}

@end
