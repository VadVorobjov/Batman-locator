//
//  WMCUserCell.h
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 04/07/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WMCUser;

@interface WMCUserCell : UITableViewCell

#pragma mark - Properties

@property (nonatomic, strong) WMCUser *user;

@end
