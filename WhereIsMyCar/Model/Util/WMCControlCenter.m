//
//  WMCControlCenter.m
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 03/07/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import "WMCControlCenter.h"

@interface WMCControlCenter()

@property (nonatomic, strong) CLGeocoder *geocoder;

@end

@implementation WMCControlCenter

#pragma mark - Properties

- (NSURLSession *)defaultSession
{
    if (_defaultSession == nil) {
        // Configuring & initializing session
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _defaultSession = [NSURLSession sessionWithConfiguration:config];
    }
    
    return _defaultSession;
}

- (CLGeocoder *)geocoder
{
    if (_geocoder == nil) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    
    return _geocoder;
}

#pragma mark - Initializers

+ (WMCControlCenter *)sharedInstance
{
    static dispatch_once_t once;
    static WMCControlCenter * shared = nil;
    
    dispatch_once(&once, ^{
        shared = [[WMCControlCenter alloc] initPrivate];
    });
    
    return shared;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[WMCControlCenter sharedStore] or CONTROL_CENTER"
                                 userInfo:nil];
    
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];
    
    return self;
}

#pragma mark - Methods

- (void)receiveTextNameOfLocation:(CLLocation *)location withCompletion:(void (^)(NSString *locationName))completion
{
    [self.geocoder reverseGeocodeLocation:location
                        completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                            if (!error) {
                                CLPlacemark *placeMark = [placemarks firstObject];
                                NSString *textName = [NSString stringWithFormat:@"%@, %@, %@",
                                                      placeMark.locality,
                                                      placeMark.thoroughfare,
                                                      placeMark.postalCode];
                                completion(textName);
                            } else {
                                completion(@"");
                            }
                        }];
}

#pragma mark - User Defaults

- (void)writeData:(NSDictionary *)data forKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *dataArchive = [NSKeyedArchiver archivedDataWithRootObject:data];
    
    [userDefaults setObject:dataArchive forKey:key];
}

- (NSDictionary *)receiveDataForKey:(NSString *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [userDefaults objectForKey:key];
    NSDictionary *unarchivedData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    return unarchivedData;
}

- (void)deleteDataForKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
