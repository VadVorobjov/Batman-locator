//
//  WMCAnnotationDetailView.h
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 05/07/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class WMCAnnotation;

@interface WMCAnnotationDetailView : UIView

#pragma mark - Properties

@property (nonatomic, strong) WMCAnnotation *annotation;

@end
