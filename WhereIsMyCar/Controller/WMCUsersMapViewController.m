//
//  WMCUsersMapViewController.m
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 03/07/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import "WMCUsersMapViewController.h"
#import "WMCUsersStore.h"
#import "WMCAnnotation.h"
#import <MapKit/MapKit.h>
#import "UIImage+WMC.h"
#import "WMCControlCenter.h"
#import "WMCAnnotationDetailView.h"

#pragma mark - Constants

double const WMCDataUpdateTimeInterval = 60.0;
NSString *const WCMAnnotationViewIdentifier = @"WCMCustomAnnotationViewIdentifier";

@interface WMCUsersMapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, strong) NSTimer *dataUpdateTimer;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation WMCUsersMapViewController

#pragma mark - Properties

- (UIAlertController *)alertController
{
    if (_alertController == nil) {
        _alertController = [UIAlertController alertControllerWithTitle:@"Oh NO!"
                                                               message:@"Sorry, but we couldn't download some/all data"
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self dataUpdateSchedule];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [self.dataUpdateTimer invalidate];
    self.dataUpdateTimer = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Simple location manager
    self.locationManager = [[CLLocationManager alloc] init];
    
    if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapView.showsUserLocation = YES;
    } else {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self centerMapByLocation:self.locationManager.location andLocationDistance:5000];
    
    [self loadData];
}

- (void)dealloc
{
    [self.dataUpdateTimer invalidate];
    self.dataUpdateTimer = nil;
}

#pragma mark - Data

- (void)dataUpdateSchedule
{
    self.dataUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:WMCDataUpdateTimeInterval
                                                          target:self
                                                        selector:@selector(loadData)
                                                        userInfo:nil
                                                         repeats:YES];
}

- (void)loadData
{
    // Clear Annotations
    [self.mapView removeAnnotations:[self.mapView annotations]];
    
    if (self.loadType == WMCUsersMapLoadTypeProvidedUser) {
        // Show coordinates for provided user's vehicles
        [self loadDataForProvidedUser];
        
    } else {
        // Show coordinates for all Users & their Vehicles
        [self loadDataForAllUsers];
    }
}

- (void)loadDataForProvidedUser
{
    WeakSelf weakSelf = self;

    [USERS_STORE receiveUserVehiclesCoordinates:self.providedUser withCompletion:^(NSDictionary *userVehiclesLocations, NSError *error) {
        
        if (!error) {
            // === Taking all vehicles coordinates of provided user ===
            NSDictionary *allVehiclesCoordinatesDict = [userVehiclesLocations objectForKey:weakSelf.providedUser.identifier];
            
            // === Taking coordinates of each vehicle of provided user step by step ===
            for (WMCVehicle *vehicle in weakSelf.providedUser.vehicle) {
                
                if ([allVehiclesCoordinatesDict objectForKey:vehicle.identifier]) {
                    
                    // === Setting map annotation ===
                    [weakSelf provideMapAnnotationFromVehicleData:vehicle
                                                      forLocation:[allVehiclesCoordinatesDict objectForKey:vehicle.identifier]];
                }
            }
        } else {
            // === Console output ===
            NSLog(@"- (void)loadData: receiveUserVehiclesCoordinatesWithCompletion: No Data received");
            [weakSelf showAlertViewController];
        }
    }];
}

- (void)loadDataForAllUsers
{
    WeakSelf weakSelf = self;

    [USERS_STORE receiveUsersVehiclesCoordinatesForUsers:USERS_STORE.allUsers withCompletion:^(NSDictionary *usersVehiclesLocations, NSError *error) {
        
        if (!error) {
            // === Taking each user ===
            for (WMCUser *user in USERS_STORE.allUsers) {
                
                // === Taking all vehicles coordinates of current user ===
                NSDictionary *allVehiclesCoordinatesDict = [usersVehiclesLocations objectForKey:user.identifier];
                
                // === Taking coordinates of each vehicle of current user step by step ===
                for (WMCVehicle *vehicle in user.vehicle) {
                    
                    if ([allVehiclesCoordinatesDict objectForKey:vehicle.identifier]) {
                        
                        // === Setting map annotation ===
                        [weakSelf provideMapAnnotationFromVehicleData:vehicle
                                                          forLocation:[allVehiclesCoordinatesDict objectForKey:vehicle.identifier]];
                    }
                }
            }
        } else {
            NSLog(@"- (void)loadData: receiveUsersVehiclesCoordinatesWithCompletion: No Data received");
            [weakSelf showAlertViewController];
        }
    }];
}

#pragma mark - Methods

- (void)centerMapByLocation:(CLLocation *)location andLocationDistance:(CLLocationDistance)locationDistance
{
    MKCoordinateRegion coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                             locationDistance,
                                                                             locationDistance);
    [self.mapView setRegion:coordinateRegion animated:YES];
}

- (void)provideMapAnnotationFromVehicleData:(WMCVehicle *)vehicle forLocation:(CLLocation *)location
{
        // Configuring annotation
        WMCAnnotation *annotation = [[WMCAnnotation alloc] initWithTitle:[NSString stringWithFormat:@"%@ %@", vehicle.make, vehicle.model] 
                                                                subtitle:@""
                                                                   color:vehicle.color
                                                                   image:vehicle.photo
                                                           andCoordinate:location.coordinate];
        // Adding annotation to the map
        [self.mapView addAnnotation:annotation];
}

- (void)showAlertViewController
{
    // Handle for possible error on situation when second view wants to be presented modally
    @try {
        [self presentViewController:self.alertController animated:YES completion:nil];
    }
    @catch (NSException *exception) {
        // Console error output
        NSLog(@"- (void)showAlertViewController: %@", exception.description);
    }
}

#pragma mark - MapView Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    // === Don't do any customization if Annotation is - MKUserLocation ===
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    } else {
        if ([annotation isKindOfClass:[WMCAnnotation class]]) {
            MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:WCMAnnotationViewIdentifier];
            
            // === Check for available MKAnnotationView ===
            if (annotationView) {
                annotationView.annotation = annotation;
            } else {
                // === Configuring new MKAnnotationView ===
                annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:WCMAnnotationViewIdentifier];
                annotationView.canShowCallout = YES;
            }
            
            // === Right Callout button ===
            UIButton *rightCalloutButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            annotationView.rightCalloutAccessoryView = rightCalloutButton;
            
            // === Details Callout
            if (@available(iOS 9.0, *)) {
                WMCAnnotationDetailView *detailsView = [[[NSBundle mainBundle] loadNibNamed:WMCAnnotationDetailViewXIB owner:self options:nil] lastObject];
                annotationView.detailCalloutAccessoryView = detailsView;
            }
            
            // === Annotation custom image ===
            annotationView.image = [UIImage imageNamed:@"Annotation.png"];
            
            return annotationView;
            
        } else {
            return nil;
        }
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[WMCAnnotation class]]) {
        WMCAnnotation *annotation = (WMCAnnotation *)view.annotation;
        CLLocation *location = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude
                                                          longitude:annotation.coordinate.longitude];

        [CONTROL_CENTER receiveTextNameOfLocation:location withCompletion:^(NSString *locationName) {
            if (@available(iOS 9.0, *)) {
                WMCAnnotationDetailView *detailView = (WMCAnnotationDetailView *)view.detailCalloutAccessoryView;
               
                annotation.subtitle = locationName;
                
                [detailView setAnnotation:annotation];
            }
        }];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    WMCAnnotation *annotation = (WMCAnnotation *)view.annotation;
    NSDictionary *launchOptions = @{ MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving };
    
    [[annotation mapItem] openInMapsWithLaunchOptions:launchOptions];
}

@end
