//
//  FaceRecCommonTools.m
//  OpenCV-FaceRec-Tutorial-iOS
//
//  Created by Fenix Lux on 16/02/16.
//  Copyright © 2016 Giovanni Murru. All rights reserved.
//

#import "FaceRecCommonTools.h"

@implementation FaceRecCommonTools

+ (void) readCSV:(const string&)filename images:(vector<Mat>&)images labels:(vector<int>&)labels separator:(char)separator
{
    std::ifstream file(filename.c_str(), ifstream::in);
    if (!file)
    {
        string error_message = "No valid input file was given, please check the given filename.";
        CV_Error(Error::StsBadArg, error_message);
    }
    string line, path, classlabel;
    int count = 1;
    while (getline(file, line))
    {
        stringstream liness(line);
        getline(liness, path, separator);
        getline(liness, classlabel);
        if(!path.empty() && !classlabel.empty())
        {
            cout << " Reading file " <<  setw(3) << setfill('0') << count << "\t\tpath: " << path;
            size_t pathLength = path.length();
            while (pathLength < 50)
            {
                cout << " ";
                pathLength++;
            }
            cout << "label: " << classlabel << endl;
            
            NSString* filePath = [[NSBundle mainBundle]
                                  pathForResource:[NSString stringWithUTF8String:path.c_str()] ofType:@"pgm"];
            NSData *imageData = [NSData dataWithContentsOfFile:filePath];
            
            cv::Mat cvImage = cv::imdecode(Mat(1, (int)[imageData length], CV_8UC1, (void*)imageData.bytes), CV_LOAD_IMAGE_UNCHANGED);
            
            images.push_back(cvImage);
            labels.push_back(atoi(classlabel.c_str()));
            ++count;
        }
    }
}

+ (void)readCSV:(const string&)filename images:(vector<Mat>&)images labels:(vector<int>&)labels
{
    [FaceRecCommonTools readCSV:filename images:images labels:labels separator:';'];
}


+(Mat)norm_0_255:(InputArray)ia
{
    Mat src = ia.getMat();
    // Create and return normalized image:
    Mat dst;
    switch(src.channels()) {
        case 1:
            cv::normalize(ia, dst, 0, 255, NORM_MINMAX, CV_8UC1);
            break;
        case 3:
            cv::normalize(ia, dst, 0, 255, NORM_MINMAX, CV_8UC3);
            break;
        default:
            src.copyTo(dst);
            break;
    }
    return dst;
}

+ (void)printFormattedTime:(int)timeInSeconds
{
    int formattedTimeHours = 0;
    int formattedTimeMinutes = 0;
    int formattedTimeSeconds = 0;
    
    if (timeInSeconds >= 3600)
    {
        formattedTimeHours = (int) timeInSeconds/60;
        timeInSeconds = timeInSeconds % 60;
    }
    if (timeInSeconds >= 60)
    {
        formattedTimeMinutes = (int) timeInSeconds/60;
        timeInSeconds = timeInSeconds % 60;
    }
    if (timeInSeconds > 0)
    {
        formattedTimeSeconds = timeInSeconds;
    }
    
    printf("Training time was %02d:%02d:%02d\n", formattedTimeHours, formattedTimeMinutes, formattedTimeSeconds);
}


@end
