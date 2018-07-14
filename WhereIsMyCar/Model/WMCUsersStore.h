//
//  WMCUsersStore.h
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 01/07/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WMCUser.h"
#import "WMCVehicle.h"

#pragma mark - Macros

#define USERS_STORE     [WMCUsersStore sharedInstance]

#pragma mark - Notifications

extern NSString *const WMCUsersStoreDidFinishUsersDataDownload;

@interface WMCUsersStore : NSObject

#pragma mark - Properties

@property (nonatomic, readonly) NSArray *allUsers;

#pragma mark - Initializers

+ (WMCUsersStore *)sharedInstance;

#pragma mark - Methods


/**
 Parses provided JSON Object according to class's properties
 
 @param jsonData JSON Object for parsing
 @param completion with indication of parsing success(YES/NO)
 */
- (void)parseUsersDataFromJsonObjectWithData:(NSDictionary *)jsonData withCompletion:(void (^)(BOOL success))completion;

/**
 Parse JSON Object(provided in the method) for coordinates of vehicles of all Users

 @param completion sends back an NSDictionary with 'userId' : (vehicleId : coordinates)
 */
- (void)receiveUsersVehiclesCoordinatesForUsers:(NSArray *)users withCompletion:(void (^)(NSDictionary * usersVehiclesLocations, NSError *error))completion;

/**
 Checks for cached user vehicles coordinates. If there is now, then Parse JSON Object(provided in the method) for coordinates of vehicles of provided user

 @param user for who to receive vehicles coordinates
 @param completion send back an NSDictionary with 'userId' : (vehicleId : coordinates)
 */
- (void)receiveUserVehiclesCoordinates:(WMCUser *)user
                        withCompletion:(void (^)(NSDictionary *userVehiclesLocations, NSError *error))completion;

@end
