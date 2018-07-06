//
//  WMCUserCell.m
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 04/07/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import "WMCUserCell.h"
#import "WMCUser.h"

@interface WMCUserCell()

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userTitle;
@property (weak, nonatomic) IBOutlet UILabel *userVehicleMake;

@end

@implementation WMCUserCell


#pragma mark - Properties

- (void)setUser:(WMCUser *)user
{
    _user = user;
    
    if (_user != nil) {
        self.userImageView.image = _user.photo;
        self.userTitle.text = [NSString stringWithFormat:@"%@ %@", _user.name, _user.surname];
        self.userVehicleMake.text = [_user receiveVehiclesMakesSeparetedBy:@","];
    }
}

@end
