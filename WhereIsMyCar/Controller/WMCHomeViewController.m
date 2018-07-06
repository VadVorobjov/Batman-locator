//
//  WMCHomeViewController.m
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 30/06/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import "WMCHomeViewController.h"
#import "WMCUsersListViewController.h"
#import "WMCUsersStore.h"
#import "WMCControlCenter.h"
#import "WMCDefinitions.h"

@interface WMCHomeViewController ()

@property (nonatomic, strong) UIAlertController *alertController;

@end

@implementation WMCHomeViewController

#pragma mark - Properties

- (UIAlertController *)alertController
{
    if (_alertController == nil) {
        _alertController = [UIAlertController alertControllerWithTitle:@"Oh NO!"
                                                               message:@"Sorry, but we couldn't download some/all data."
                                                        preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self dismissViewControllerAnimated:YES completion:nil];
                                                         }];
        
        UIAlertAction *tryAgain = [UIAlertAction actionWithTitle:@"Try again!" style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self loadData];
                                                                 [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [_alertController addAction:okAction];
        [_alertController addAction:tryAgain];
    }
    
    return _alertController;
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
}

#pragma mark - Data Fetching

- (void)loadData
{
    WeakSelf weakSelf = self;
    
    NSString *requestString = @"http://mobi.connectedcar360.net/api/?op=list";
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];

    NSURLSessionDataTask *dataTask = [CONTROL_CENTER.defaultSession dataTaskWithRequest:urlRequest
                                                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                         
                                                         if (!error) {
                                                             NSError *jsonError;
                                                             NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                                             
                                                             if (!jsonError) {
                                                                 [USERS_STORE parseUsersDataFromJsonObjectWithData:jsonData];
                                                                 
                                                             } else {
                                                                 // Console error output
                                                                 NSLog(@"- (void)loadData: error on parsing json: %@", jsonError.localizedDescription);
                                                                 
                                                                 // In case of Error - presenting Alert controller to the user
                                                                 [weakSelf presentViewController:weakSelf.alertController animated:YES completion:nil];
                                                             }
                                                             
                                                         } else {
                                                             // Console error output
                                                             NSLog(@"- (void)loadData: error on executing dataTask: %@", error.localizedDescription);
                                                             
                                                             // In case of Error - presenting Alert controller to the user
                                                             [weakSelf presentViewController:weakSelf.alertController animated:YES completion:nil];
                                                         }
                                                     }];
    // Execute
    [dataTask resume];
}

@end
