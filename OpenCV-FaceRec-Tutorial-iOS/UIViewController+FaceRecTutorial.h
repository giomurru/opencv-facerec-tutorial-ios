//
//  UIViewController+FaceRecTutorial.h
//  OpenCV-FaceRec-Tutorial-iOS
//
//  Created by Fenix Lux on 16/02/16.
//  Copyright © 2016 Giovanni Murru. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (FaceRecTutorial)
- (UILabel *)createPleaseWaitMessage;
- (UILabel *)createTutorialTitle:(NSString *)tutorialTitle;
- (UILabel *)createReconstructionTitle:(CGFloat)yPosition;
@end
