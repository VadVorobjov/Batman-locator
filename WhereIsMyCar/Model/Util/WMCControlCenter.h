//
//  WMCControlCenter.h
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 03/07/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#pragma mark - Macros

#define CONTROL_CENTER     [WMCControlCenter sharedInstance]

@interface WMCControlCenter : NSObject

#pragma mark - Properties

@property (nonatomic, strong) NSURLSession *defaultSession;

#pragma mark - Initializers

+ (WMCControlCenter *)sharedInstance;

#pragma mark - Methods

/**
 Provides user friendly name for the provided location coordinates(ex. London. Barkley str. 18)

 @param location for converting to human readable string
 @param completion NSString with human readable location name
 */
- (void)receiveTextNameOfLocation:(CLLocation *)location withCompletion:(void (^)(NSString *locationName))completion;

#pragma mark - User Defaults

- (void)writeData:(NSDictionary *)data forKey:(NSString *)key;
- (NSDictionary *)receiveDataForKey:(NSString *)key;
- (void)deleteDataForKey:(NSString *)key;

@end
