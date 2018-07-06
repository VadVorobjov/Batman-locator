//
//  WMCUser.h
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 30/06/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMCVehicle.h"

@interface WMCUser : NSObject

#pragma mark - Properties

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *surname;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) NSMutableArray <WMCVehicle *> *vehicle;

#pragma mark - Methods

/**
 For getting all user's vehicles makes in a single string

 @param separator sign that will separate makes
 @return NSString of makes separated by separator param
 */
- (NSString *)receiveVehiclesMakesSeparetedBy:(NSString *)separator;

@end
