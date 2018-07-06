//
//  WMCVehicle.h
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 01/07/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WMCVehicle : NSObject

#pragma mark - Properties

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) NSString *make;
@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *vin;
@property (nonatomic, strong) NSString *year;

@end
