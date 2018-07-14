//
//  WMCUsersStore.m
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 01/07/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import "WMCUsersStore.h"
#import "UIImage+WMC.h"
#import "UIColor+WMC.h"
#import <MapKit/MapKit.h>
#import "WMCControlCenter.h"
#import "WMCDefinitions.h"

#pragma mark - Notifications

NSString *const WMCUsersStoreDidFinishUsersDataDownload = @"com.vadims.projects.usersstore.users.data.downloaded";
NSString *const WMCCachedUsersVehiclesLocationsKey = @"com.vadims.projects.users.vehicles.cached.location.key";

#pragma mark - Constants

double const WMCCachedTimeInterval = 30.0;

@interface WMCUsersStore()

// Properties for private use
@property (nonatomic, strong) NSMutableArray *privateUsers;
@property (nonatomic, strong) NSDictionary *privateCachedUsersVehiclesLocations;

// Properties
@property (nonatomic, strong) NSTimer *cacheTimer;

@end

@implementation WMCUsersStore

#pragma mark - Properties

/**
 Used to configure a non-repeat NSTimer to fire a clear cache event

 @return NSTimer with configuration for clearing cache
 */
- (NSTimer *)configuredCacheTimer
{
    return [NSTimer scheduledTimerWithTimeInterval:WMCCachedTimeInterval
                                            target:self
                                          selector:@selector(destroyCache)
                                          userInfo:nil
                                           repeats:NO];
}

/**
 Used to return all available users 'WMCUser'(readonly)

 @return readonly property
 */
- (NSArray *)allUsers
{
    return self.privateUsers;
}

/**
 Used to set User's Vehicles locations and start destroy timer of assigned data(considered to become outdated)

 @param privateCachedUsersVehiclesLocations User's Vehicles locations
 */
- (void)setPrivateCachedUsersVehiclesLocations:(NSDictionary *)privateCachedUsersVehiclesLocations
{
    [CONTROL_CENTER writeData:privateCachedUsersVehiclesLocations forKey:WMCCachedUsersVehiclesLocationsKey];
    
    if (self.cacheTimer == nil) {
        // Create new timer
        self.cacheTimer = [self configuredCacheTimer];
    } else {
        // Restart timer
        [self.cacheTimer invalidate];
        self.cacheTimer = [self configuredCacheTimer];
    }
}

- (NSDictionary *)privateCachedUsersVehiclesLocations
{
    return [CONTROL_CENTER receiveDataForKey:WMCCachedUsersVehiclesLocationsKey];
}

- (void)destroyCache
{
    // Destroy timer & cache
    [self.cacheTimer invalidate];
    self.cacheTimer = nil;
    [CONTROL_CENTER deleteDataForKey:WMCCachedUsersVehiclesLocationsKey];
}

#pragma mark - Initializers

+ (WMCUsersStore *)sharedInstance
{
    static dispatch_once_t once;
    static WMCUsersStore * shared = nil;
    
    dispatch_once(&once, ^{
        shared = [[WMCUsersStore alloc] initPrivate];
    });
    
    return shared;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[WMCUsersStore sharedStore] or USERS_STORE"
                                 userInfo:nil];
    
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    
    if (self) {
        _privateUsers = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark - Methods

- (void)parseUsersDataFromJsonObjectWithData:(NSDictionary *)jsonData withCompletion:(void (^)(BOOL))completion
{
    // Group for waiting download of all images before invoking completion block
    dispatch_group_t imageDownloadGroup = dispatch_group_create();
    
    NSNumber *numberId;
    NSDictionary *usersDict = [[NSMutableDictionary alloc] init];
    NSDictionary *vehiclesDict = [[NSMutableDictionary alloc] init];

    // === For any possible error during JSON parsing ===
    @try {
        for (NSDictionary *dict in jsonData[@"data"]) {
            // Check if we have 'owner' data. Otherwise we consider whole current data batch as inconsistent.
            if ([self checkValueIn:dict forKey:@"owner"]) {
                
                    numberId = dict[@"userid"];
                    usersDict = dict[@"owner"];
                    vehiclesDict = dict[@"vehicles"];
                
                    WMCUser *user = [[WMCUser alloc] init];
                
                    // Parsing 'Owner' data
                    user.identifier = [self checkValueIn:dict forKey:@"userid"] ? numberId.stringValue : @"";
                    user.name = [self checkValueIn:usersDict forKey:@"name"] ? usersDict[@"name"] : @"";
                    user.surname = [self checkValueIn:usersDict forKey:@"surname"] ? usersDict[@"surname"] : @"";
                
                    // Downloading & assigning image
                    dispatch_group_enter(imageDownloadGroup);
                    [UIImage downloadImageFromURL:usersDict[@"foto"] completionBlock:^(BOOL success, UIImage *image) {
                        if (success) {
                            user.photo = image;
                        }
                        dispatch_group_leave(imageDownloadGroup);
                    }];
                
                    // Parsing 'Vehicles' data
                    for (NSDictionary *vehicle in vehiclesDict) {
                        WMCVehicle *userVehicle = [[WMCVehicle alloc] init];
                        
                        numberId = vehicle[@"vehicleid"];
                        userVehicle.identifier = [self checkValueIn:vehicle forKey:@"vehicleid"] ? numberId.stringValue : @"";
                        userVehicle.color = [self checkValueIn:vehicle forKey:@"color"] ? [UIColor colorWithHexString:vehicle[@"color"]] : nil;
                        userVehicle.make = [self checkValueIn:vehicle forKey:@"make"] ? vehicle[@"make"] : @"";
                        userVehicle.model = [self checkValueIn:vehicle forKey:@"model"] ? vehicle[@"model"] : @"";
                        userVehicle.vin = [self checkValueIn:vehicle forKey:@"vin"] ? vehicle[@"vin"] : @"";
                        userVehicle.year = [self checkValueIn:vehicle forKey:@"year"] ? vehicle[@"year"] : @"";
                        
                        // Downloading & assigning image
                        dispatch_group_enter(imageDownloadGroup);
                        [UIImage downloadImageFromURL:vehicle[@"foto"] completionBlock:^(BOOL success, UIImage *image) {
                            if (success && image) {
                                userVehicle.photo = image;
                            } else {
                                userVehicle.photo = [UIImage imageNamed:@"Batcycle"];
                            }
                            dispatch_group_leave(imageDownloadGroup);
                        }];
                        
                        // Assigning vehicle data to user
                        [user.vehicle addObject:userVehicle];
                    }
                
                    // Adding User data to private array
                    [self.privateUsers addObject:user];
            }
        }
    
        // Invoked after all images are downloaded.
        dispatch_group_notify(imageDownloadGroup, dispatch_get_main_queue(), ^{
            // Console output
            NSLog(@"- (void)parseUsersDataFromJsonObjectWithData: JSON data's parsing completed.");
            
            // Completion
            completion(YES);
            
            // Send notification to controllers which rely on updated data
            [[NSNotificationCenter defaultCenter] postNotificationName:WMCUsersStoreDidFinishUsersDataDownload object:nil];
        });
        
    } @catch (NSException *exception) {
        // Console error output
        NSLog(@"- (void)parseUsersDataFromJsonObjectWithData: Warning! JSON has inconsistent data %@", exception.description);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Completion
            completion(NO);
        });
    }
}

- (void)receiveUsersVehiclesCoordinatesForUsers:(NSArray *)users withCompletion:(void (^)(NSDictionary * usersVehiclesLocations, NSError *error))completion
{
    // Group for waiting download of all user's vehicles coordinates before invoking completion block
    dispatch_group_t coordinatesDownloadGroup = dispatch_group_create();
    
    WeakSelf weakSelf = self;
    
    __block NSError *receivedError = nil;
    __block BOOL someDataWasDownloaded = NO;
    NSMutableDictionary *tempUsersVehiclesLocations = [[NSMutableDictionary alloc] init];
    
    // === Loading vehicle data for each user ===
    for (WMCUser *user in users) {
        NSString *requestString = [NSString stringWithFormat:@"http://mobi.connectedcar360.net/api/?op=getlocations&userid=%@", user.identifier];
        NSURL *url = [NSURL URLWithString:requestString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        
        dispatch_group_enter(coordinatesDownloadGroup);
        NSURLSessionDataTask *dataTask = [CONTROL_CENTER.defaultSession dataTaskWithRequest:urlRequest
                                                         completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                             
                                                             // === Checking if there was no error ===
                                                             if (!error) {
                                                                 
                                                                 // === Parsing received JSON Object ===
                                                                 NSError *jsonError;
                                                                 NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                                                 
                                                                 // === Checking if there was no error ===
                                                                 if (!jsonError) {
                                                                     NSMutableDictionary *vehicleCoordinates = [[NSMutableDictionary alloc] init];
                                                                     
                                                                     // === Parsing user's vehicles coordinates ===
                                                                     for (NSDictionary *dict in jsonData[@"data"]) {
                                                                         @try {
                                                                             
                                                                             // === Keys for dictionary values ===
                                                                             NSArray *dictKeys = [[NSArray alloc] initWithObjects:
                                                                                                  @"vehicleid",
                                                                                                  @"lat",
                                                                                                  @"lon",
                                                                                                  nil];
                                                                             
                                                                             // === Check Dictionary for valid 'key-value', so we can proceed with parsing ===
                                                                             if ([weakSelf checkValueIn:dict forKeys:dictKeys]) {
                                                                                 NSNumber *numberId = dict[@"vehicleid"];
                                                                                 NSNumber *lat = dict[@"lat"];
                                                                                 NSNumber *lon = dict[@"lon"];
                                                                                 
                                                                                 CLLocation *coordinates = [[CLLocation alloc] initWithLatitude:lat.doubleValue
                                                                                                                                      longitude:lon.doubleValue];
                                                                                 // === Storing vehicle's coordinates ===
                                                                                 [vehicleCoordinates setValue:coordinates forKey:numberId.stringValue];
                                                                                 // === Setting Flag to acknowledge, that we have valid data ===
                                                                                 someDataWasDownloaded = YES;
                                                                             }
                                                                             
                                                                         } @catch (NSException *exception) {
                                                                             // === Console error output ===
                                                                             NSLog(@"- (void)receiveUsersVehiclesCoordinatesForUsers: Warning! JSON has inconsistent data %@", exception.description);
                                                                         }
                                                                     }
                                                                     
                                                                     // === Storing current user's parsed vehicles with coordinates ===
                                                                     [tempUsersVehiclesLocations setObject:vehicleCoordinates forKey:user.identifier];
                                                                     
                                                                 } else {
                                                                     
                                                                     receivedError = jsonError;
                                                                     
                                                                     // === Console error output ===
                                                                     NSLog(@"- (void)receiveUsersVehiclesCoordinatesWithCompletion: couldn't parse vehicles coordinates for user %@. %@", user.identifier, jsonError.localizedDescription);
                                                                 }

                                                             } else {
                                                                 
                                                                 receivedError = error;
                                                                 
                                                                 // === Console error output ===
                                                                 NSLog(@"- (void)receiveUsersVehiclesCoordinatesWithCompletion: couldn't receive vehicles coordinates for user %@. %@", user.identifier, error.localizedDescription);
                                                             }
                                                             
                                                             dispatch_group_leave(coordinatesDownloadGroup);
                                                         }];
        // Execute
        [dataTask resume];
    }
    
    // === Invoked after all download procedures are finished ===
    dispatch_group_notify(coordinatesDownloadGroup, dispatch_get_main_queue(), ^{
        // === Console output ===
        NSLog(@"- (void)receiveUsersVehiclesCoordinatesForUsers: JSON Vehicles coordinates data's parsing completed.");
        
        // === Assigning parsed user's vehicles coordinates ===
        weakSelf.privateCachedUsersVehiclesLocations = tempUsersVehiclesLocations;

        // === Checking if we received valid data ===
        if (someDataWasDownloaded == YES) {
            // === Callback with User's vehicles locations - All or some data was received ===
            completion(tempUsersVehiclesLocations, nil);
        } else {
            // === Callback with catched Error - No single data received ===
            completion(tempUsersVehiclesLocations, receivedError);
        }
    });
}

- (void)receiveUserVehiclesCoordinates:(WMCUser *)user withCompletion:(void (^)(NSDictionary *, NSError *))completion
{
    // If we have cached value for current user
    if ([self checkValueIn:self.privateCachedUsersVehiclesLocations forKey:user.identifier]) {
        // === Console output ===
        NSLog(@" Using cached values");
        completion(self.privateCachedUsersVehiclesLocations, nil);
        
    } else {
        // Downloading data
        [self receiveUsersVehiclesCoordinatesForUsers:[[NSArray alloc] initWithObjects:user, nil]
                                       withCompletion:^(NSDictionary *usersVehiclesLocations, NSError *error) {
                                           // Returning user vehicles location
                                           completion(usersVehiclesLocations, error);
                                       }];
    }
}

#pragma mark - Check Dictionary key-value

- (BOOL)checkValueIn:(NSDictionary *)dictionary forKey:(NSString *)key {
    return [self checkValueIn:dictionary forKeys:[[NSArray alloc] initWithObjects: key, nil]];
}

- (BOOL)checkValueIn:(NSDictionary *)dictionary forKeys:(NSArray *)keys
{
    BOOL valid = NO;
    
    for (NSString *key in keys) {
        id obj = dictionary[key];
        // If object has value
        if (obj != nil) {
            // If object's value isn't NSNull
            if (obj != [NSNull null]) {
                valid = YES;
            } else {
                valid = NO;
            }
        } else {
            valid = NO;
        }
    }
    
    return valid;
}

@end
