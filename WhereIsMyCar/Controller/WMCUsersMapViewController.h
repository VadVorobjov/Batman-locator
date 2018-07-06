//
//  WMCUsersMapViewController.h
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 03/07/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WMCDefinitions.h"

@class WMCUser;

@interface WMCUsersMapViewController : UIViewController

#pragma mark - Properties

@property (nonatomic, strong) WMCUser *providedUser;
@property (nonatomic) WMCUsersMapLoadType loadType;

@end
