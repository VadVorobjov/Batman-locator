//
//  WMCDefinitions.h
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 04/07/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Macros

#define WeakObject(o)   __typeof__(o)__weak
#define WeakSelf        WeakObject(self)

#pragma mark - Storyboards

extern NSString *const WMCMainStoryBoardName;

#pragma mark - UIViewControllers Identifiers

extern NSString *const WMCUserMapViewControllerIdentifier;

#pragma mark - UIView XIB's
extern NSString *const WMCAnnotationDetailViewXIB;

#pragma mark - UITableViewCell XIB's

extern NSString *const WMCUserCellXIBName;

#pragma mark - UITableViewCell Identifiers

extern NSString *const WMCUserCellIdentifier;

#pragma mark - Enums

typedef NS_ENUM(NSInteger, WMCUsersMapLoadType) {
    WMCUsersMapLoadTypeAllUsers,    // Default
    WMCUsersMapLoadTypeProvidedUser
};
