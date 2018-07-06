//
//  WMCAnnotationDetailView.m
//  WhereIsMyCar
//
//  Created by Vadims Vorobjovs on 05/07/2018.
//  Copyright © 2018 Vadim's Projects. All rights reserved.
//

#import "WMCAnnotationDetailView.h"
#import "WMCAnnotation.h"

@interface WMCAnnotationDetailView()

@property (weak, nonatomic) IBOutlet UIView *color;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *locationName;

@end

@implementation WMCAnnotationDetailView

#pragma mark - Properties

- (void)setAnnotation:(WMCAnnotation *)annotation
{
    self.locationName.text = annotation.subtitle;
    self.color.backgroundColor = annotation.color;
    self.imageView.image = annotation.image;
    
    [UIView animateWithDuration:1.0 animations:^{
        [self layoutIfNeeded];
    }];
}

#pragma mark - Life cycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.color.layer.cornerRadius = self.color.frame.size.width / 2;
    self.color.layer.borderWidth = 0.5f;
    self.color.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2;
    self.imageView.clipsToBounds = YES;
}

@end
