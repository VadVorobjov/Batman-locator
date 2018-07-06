//
//  WMCUsersListViewController.m
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 30/06/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import "WMCUsersListViewController.h"
#import "WMCUsersMapViewController.h"
#import "WMCUsersStore.h"
#import "WMCUserCell.h"
#import "WMCDefinitions.h"

@interface WMCUsersListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation WMCUsersListViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    [self subscibeToNotifications];
}

- (void)dealloc
{
    [self unsubscribeToNotifications];
}

#pragma mark - UI

- (void)setupUI
{
    // Registering XIB
    [self.tableView registerNib:[UINib nibWithNibName:WMCUserCellXIBName
                                               bundle:[NSBundle mainBundle]]  forCellReuseIdentifier:WMCUserCellIdentifier];
    
    // Removing not used empty cells
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - Data

- (void)updateData
{
    [self.tableView reloadData];
}

#pragma mark - Notifications

- (void)subscibeToNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateData)
                                                 name:WMCUsersStoreDidFinishUsersDataDownload
                                               object:nil];
}

- (void)unsubscribeToNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:WMCUsersStoreDidFinishUsersDataDownload
                                                  object:nil];
}

#pragma mark - UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return USERS_STORE.allUsers.count > 0 ? USERS_STORE.allUsers.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WMCUserCell *cell = [tableView dequeueReusableCellWithIdentifier:WMCUserCellIdentifier forIndexPath:indexPath];
    
    WMCUser *user = [USERS_STORE.allUsers objectAtIndex:indexPath.row];
    
    cell.user = user;
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:WMCMainStoryBoardName bundle:[NSBundle mainBundle]];
    
    WMCUser *user = [USERS_STORE.allUsers objectAtIndex:indexPath.row];
    
    WMCUsersMapViewController *mapController = [storyBoard instantiateViewControllerWithIdentifier:WMCUserMapViewControllerIdentifier];
    
    mapController.title = user.name;
    mapController.loadType = WMCUsersMapLoadTypeProvidedUser;
    mapController.providedUser = user;
        
    [self.navigationController pushViewController:mapController animated:YES];
}
@end
