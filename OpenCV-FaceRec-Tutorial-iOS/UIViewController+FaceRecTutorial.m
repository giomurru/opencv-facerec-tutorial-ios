//
//  UIViewController+FaceRecTutorial.m
//  OpenCV-FaceRec-Tutorial-iOS
//
//  Created by Fenix Lux on 16/02/16.
//  Copyright © 2016 Giovanni Murru. All rights reserved.
//

#import "UIViewController+FaceRecTutorial.h"

@implementation UIViewController (FaceRecTutorial)


- (UILabel *)createPleaseWaitMessage
{
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 0.0f, self.view.bounds.size.width-40.0f, self.view.bounds.size.height)];
    
    infoLabel.numberOfLines = 0;
    infoLabel.text = @"Training the model.\nPlease wait...\nIt can take a couple of minutes.";
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.textColor = [UIColor blackColor];
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.font = [UIFont fontWithName:@"Helvetica" size:IS_IPAD ? 50.0f : 20.0f];
    
    return infoLabel;
}

- (UILabel *)createTutorialTitle:(NSString *)tutorialTitle
{
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.view.bounds.size.width-40.0f, 40)];
    
    infoLabel.text = tutorialTitle;
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.textColor = [UIColor blackColor];
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.font = [UIFont fontWithName:@"Helvetica" size:IS_IPAD ? 30.0f : 15.0f];
    
    return infoLabel;
}


- (UILabel *)createReconstructionTitle:(CGFloat)yPosition
{
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, yPosition, self.view.bounds.size.width-40.0f, 40)];
    
    infoLabel.text = @"The Reconstruction";
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.textColor = [UIColor blackColor];
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.font = [UIFont fontWithName:@"Helvetica" size:IS_IPAD ? 30.0f : 15.0f];
    
    return infoLabel;
}

@end
