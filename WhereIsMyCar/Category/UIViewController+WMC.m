//
//  UIViewController+WMC.m
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 14/07/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import "UIViewController+WMC.h"
#import <objc/runtime.h>

#pragma mark - Keys

static const char WMCActivityIndicatorViewKey;

@implementation UIViewController (WMC)

#pragma mark - Properties

- (UIActivityIndicatorView *)activityView
{
    UIActivityIndicatorView *activityView = objc_getAssociatedObject(self, &WMCActivityIndicatorViewKey);
    
    if (activityView == nil) {
        activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
        
        [activityView.layer setCornerRadius:15.0];
        
        [activityView setColor:[UIColor orangeColor]];
        [activityView setBackgroundColor:[UIColor blackColor]];
        [activityView setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2)];
        
        objc_setAssociatedObject(self, &WMCActivityIndicatorViewKey, activityView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return activityView;
}

#pragma mark - Methods

- (void)showActivityIndicator
{
    [self.view addSubview:self.activityView];
    [self.activityView startAnimating];
}

- (void)hideActivityIndicator
{
    [self.activityView removeFromSuperview];
    [self.activityView stopAnimating];
}

@end
