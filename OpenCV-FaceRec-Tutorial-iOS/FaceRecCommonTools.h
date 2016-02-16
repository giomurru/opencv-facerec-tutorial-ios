//
//  FaceRecCommonTools.h
//  OpenCV-FaceRec-Tutorial-iOS
//
//  Created by Fenix Lux on 16/02/16.
//  Copyright © 2016 Giovanni Murru. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "opencv2/face.hpp"

#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>

using namespace cv;
using namespace cv::face;
using namespace std;

@interface FaceRecCommonTools : NSObject
+ (void)readCSV:(const string&)filename images:(vector<Mat>&)images labels:(vector<int>&)labels separator:(char)separator;
+ (void)readCSV:(const string&)filename images:(vector<Mat>&)images labels:(vector<int>&)labels;
+ (Mat)norm_0_255:(InputArray)ia;
+ (void)printFormattedTime:(int)timeInSeconds;
@end
