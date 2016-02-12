/* This code is an adaptation of the Face recognition tutorial that you can find on the OpenCV website:
 * http://docs.opencv.org/2.4/modules/contrib/doc/facerec/facerec_tutorial.html#face-recognition-with-opencv
 *
 * Copyright (c) 2011. Philipp Wagner <bytefish[at]gmx[dot]de>.
 * Released to public domain under terms of the BSD Simplified license.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *   * Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   * Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *   * Neither the name of the organization nor the names of its contributors
 *     may be used to endorse or promote products derived from this software
 *     without specific prior written permission.
 *
 *   See <http://www.opensource.org/licenses/bsd-license>
 */

/* 
 For the modifications to the software it is valid the following licence:
 
 Copyright (c) 2016-present, Giovanni Murru. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in 
 the Software without restriction, including without limitation the rights to use, 
 copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the 
 Software, and to permit persons to whom the Software is furnished to do so, 
 subject to the following conditions:

 The above copyright notice and this permission notice shall be included 
 in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
 PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

#import "EigenfacesViewController.h"
#import "UIImage+OpenCV.h"
#include "opencv2/face.hpp"

#include <iostream>
#include <fstream>
#include <sstream>
#include <iomanip>

#define IS_IPAD [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad


using namespace cv;
using namespace cv::face;
using namespace std;

@interface EigenfacesViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *myLabel;
@property (nonatomic) BOOL modelTraining;
@end

@implementation EigenfacesViewController

+(id)sharedEigenfacesViewController
{
    static EigenfacesViewController *sharedEigenfacesViewController = nil;
    @synchronized(self)
    {
        if (sharedEigenfacesViewController == nil)
        {
            sharedEigenfacesViewController = [[self alloc] init];
        }
    }
    return sharedEigenfacesViewController;
}


#pragma mark UI Methods

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

- (UILabel *)createEigenFacesTitle
{
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.view.bounds.size.width-40.0f, 40)];
    
    infoLabel.text = @"The Eigenfaces";
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

#pragma mark View Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Eigenfaces"];
    self.scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.view = self.scrollView;
    
    self.myLabel = [self createPleaseWaitMessage];
    [self.view addSubview:self.myLabel];
    
    NSString* att_faces_path = [[NSBundle mainBundle]
                                pathForResource:@"att_faces" ofType:@"list"];
    [self runFaceDetectionAlgorithm:[att_faces_path UTF8String]];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /*
    if (self.modelTraining == NO)
    {
        for (id view in self.view.subviews)
        {
            [view removeFromSuperview];
        }
        
        // Do any additional setup after loading the view, typically from a nib.
     
    }
    else
    {
        cout << "Model is still training... wait" << endl;
    }*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

+ (void) readCSV:(const string&)filename images:(vector<Mat>&)images labels:(vector<int>&)labels
{
    [EigenfacesViewController readCSV:filename images:images labels:labels separator:';'];
}

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
            cout << " Reading file " <<  setw(3) << setfill('0') << count << "\t\tpath: " << path << "\t\tlabel: " << classlabel << endl;
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
- (void)printTrainingTime:(int)trainingTime
{
    int trainingHours = 0;
    int trainingMinutes = 0;
    int trainingSeconds = 0;
    
    if (trainingTime >= 3600)
    {
        trainingHours = (int) trainingTime/60;
        trainingTime = trainingTime % 60;
    }
    if (trainingTime >= 60)
    {
        trainingMinutes = (int) trainingTime/60;
        trainingTime = trainingTime % 60;
    }
    if (trainingTime > 0)
    {
        trainingSeconds = trainingTime;
    }
    
    printf("Training time was %02d:%02d:%02d\n", trainingHours, trainingMinutes, trainingSeconds);
}



- (void)runFaceDetectionAlgorithm:(const char *)csvPath
{
    CGFloat thumbsWidth;
    int numOfThumbsPerRow;
    if (IS_IPAD)
    {
        thumbsWidth = 128.0f;
        numOfThumbsPerRow = 6;
    }
    else
    {
        thumbsWidth = 80.0f;
        numOfThumbsPerRow = 4;
    }
    
    cout << "Running Face Detection Algorithm" << endl;
    // Get the path to your CSV.
    string fn_csv = string(csvPath);
    // These vectors hold the images and corresponding labels.
    vector<Mat> images;
    vector<int> labels;
    // Read in the data. This can fail if no valid
    // input filename is given.
    try
    {
        cout << "Reading csv database file containing paths to images and labels for each image" << endl;
        [EigenfacesViewController readCSV:fn_csv images:images labels:labels];
    }
    catch (cv::Exception& e) {
        cerr << "Error opening file \"" << fn_csv << "\". Reason: " << e.msg << endl;
        // nothing more we can do
        return;
    }
    // Quit if there are not enough images for this demo.
    if(images.size() <= 1)
    {
        string error_message = "This demo needs at least 2 images to work. Please add more images to your data set!";
        CV_Error(Error::StsError, error_message);
    }
    // Get the height from the first image. We'll need this
    // later in code to reshape the images to their original
    // size:
    int height = images[0].rows;
    // The following lines simply get the last images from
    // your dataset and remove it from the vector. This is
    // done, so that the training data (which we learn the
    // cv::BasicFaceRecognizer on) and the test data we test
    // the model with, do not overlap.
    Mat testSample = images[images.size() - 1];
    int testLabel = labels[labels.size() - 1];
    images.pop_back();
    labels.pop_back();
    // The following lines create an Eigenfaces model for
    // face recognition and train it with the images and
    // labels read from the given CSV file.
    // This here is a full PCA, if you just want to keep
    // 10 principal components (read Eigenfaces), then call
    // the factory method like this:
    //
    //      cv::createEigenFaceRecognizer(10);
    //
    // If you want to create a FaceRecognizer with a
    // confidence threshold (e.g. 123.0), call it with:
    //
    //      cv::createEigenFaceRecognizer(10, 123.0);
    //
    // If you want to use _all_ Eigenfaces and have a threshold,
    // then call the method like this:
    //
    //      cv::createEigenFaceRecognizer(0, 123.0);
    //
    cout << "Create Eigen Face Recognizer model" << endl;
    Ptr<BasicFaceRecognizer> _model = createEigenFaceRecognizer();
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    
    self.modelTraining = YES;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docs = [paths objectAtIndex:0];
        NSString *savedDataPath = [docs stringByAppendingPathComponent:@"eigenfaces_at.xml"];
        
        BOOL savedDataExists = [[NSFileManager defaultManager] fileExistsAtPath:savedDataPath];
        
        if (savedDataExists)
        {
            cout << "Loading previously saved training data." << endl;
            //dispatch_async(dispatch_get_main_queue(), ^{
            FileStorage fs([savedDataPath UTF8String], FileStorage::READ);
            _model->load(fs);
            fs.release();
                
            //});
        }
        else
        {
            cout << "No previously saved data found." << endl;
            cout << "Train the model. Please wait while training... " << endl;
            _model->train(images, labels);
            
            //dispatch_async(dispatch_get_main_queue(), ^{
            FileStorage fs([savedDataPath UTF8String], FileStorage::WRITE);
            _model->save(fs);
            fs.release();
            //});
            
            cout << "Training data has been saved" << endl;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.myLabel removeFromSuperview];
            
            int trainingTime = (int) [[NSDate date] timeIntervalSince1970] - startTime;
            
            [self printTrainingTime:trainingTime];
            
            //[infoLabel removeFromSuperview];
            
            // The following line predicts the label of a given
            // test image:
            cout << "Predicting the class of a given image" << endl;
            int predictedLabel = _model->predict(testSample);
            //
            // To get the confidence of a prediction call the model with:
            //
            //      int predictedLabel = -1;
            //      double confidence = 0.0;
            //      model->predict(testSample, predictedLabel, confidence);
            //
            string result_message = format("Predicted class = %d / Actual class = %d.", predictedLabel, testLabel);
            cout << result_message << endl;
            // Here is how to get the eigenvalues of this Eigenfaces model:
            Mat eigenvalues = _model->getEigenValues();
            // And we can do the same to display the Eigenvectors (read Eigenfaces):
            Mat W = _model->getEigenVectors();
            // Get the sample mean from the training data
            Mat mean = _model->getMean();
            Mat meanNorm = [EigenfacesViewController norm_0_255:mean.reshape(1, images[0].rows)];
            // Display or save:
            // Display or save the Eigenfaces:
            CGFloat uiimgX = 0.0f;
            
            UILabel *eigenfacesTitle = [self createEigenFacesTitle];
            CGFloat uiimgY = eigenfacesTitle.frame.size.height;

            [self.view addSubview:eigenfacesTitle];
            
            for (int i = 0; i < min(10, W.cols); i++)
            {
                if (i>0 && i%numOfThumbsPerRow==0)
                {
                    uiimgX = 0.0f;
                    uiimgY += thumbsWidth;
                }
                
                string msg = format("Eigenvalue #%d = %.5f", i, eigenvalues.at<double>(i));
                cout << msg << endl;
                // get eigenvector #i
                Mat ev = W.col(i).clone();
                // Reshape to original size & normalize to [0...255] for imshow.
                Mat grayscale = [EigenfacesViewController norm_0_255:ev.reshape(1, height)];
                // Show the image & apply a Jet colormap for better sensing.
                Mat cgrayscale;
                applyColorMap(grayscale, cgrayscale, COLORMAP_JET);
                
                std::vector<uchar> imgBuffer;
                cv::imencode(".png", cgrayscale, imgBuffer);
                
                NSData *uiimgData = [NSData dataWithBytes:imgBuffer.data() length:imgBuffer.size()];
                UIImage *uiimg = [UIImage imageWithData:uiimgData];
                UIImageView *uiimgView = [[UIImageView alloc] initWithImage:uiimg];
                uiimgView.frame = CGRectMake(uiimgX, uiimgY, thumbsWidth, thumbsWidth);
                [self.view addSubview:uiimgView];
                
                
                uiimgX += thumbsWidth;
                
            }
            
            uiimgX = 0.0f;
            uiimgY += thumbsWidth;
            
            UILabel *reconstructionTitleLabel = [self createReconstructionTitle:uiimgY];
            [self.view addSubview:reconstructionTitleLabel];
            
            uiimgY += reconstructionTitleLabel.frame.size.height;
            
            // Display or save the image reconstruction at some predefined steps:
            int i = 0;
            for(int num_components = min(W.cols, 10); num_components < min(W.cols, 300); num_components+=15)
            {
                
                if (i>0 && i%numOfThumbsPerRow==0)
                {
                    uiimgX = 0.0f;
                    uiimgY += thumbsWidth;
                }
                cout << "Reconstruction #" <<  setw(2) << setfill('0') << i << ": num_components " << num_components << endl;
                // slice the eigenvectors from the model
                Mat evs = Mat(W, Range::all(), Range(0, num_components));
                Mat projection = LDA::subspaceProject(evs, mean, images[0].reshape(1,1));
                Mat reconstruction = LDA::subspaceReconstruct(evs, mean, projection);
                // Normalize the result:
                reconstruction = [EigenfacesViewController norm_0_255:reconstruction.reshape(1, images[0].rows)];
                
                std::vector<uchar> imgBuffer;
                cv::imencode(".png", reconstruction, imgBuffer);
                
                NSData *uiimgData = [NSData dataWithBytes:imgBuffer.data() length:imgBuffer.size()];
                UIImage *uiimg = [UIImage imageWithData:uiimgData];
                UIImageView *uiimgView = [[UIImageView alloc] initWithImage:uiimg];
                uiimgView.frame = CGRectMake(uiimgX, uiimgY, thumbsWidth, thumbsWidth);
                [self.view addSubview:uiimgView];
                
                uiimgX += thumbsWidth;
                ++i;
            }
            
            self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, uiimgY + thumbsWidth);
            
            self.modelTraining = NO;
        });
    });
}

@end
