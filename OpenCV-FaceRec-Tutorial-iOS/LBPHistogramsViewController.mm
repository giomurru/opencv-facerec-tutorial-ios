//
//  LocalBinaryPatternsHistogramsViewController.m
//  OpenCV-FaceRec-Tutorial-iOS
//
//  Created by Fenix Lux on 16/02/16.
//  Copyright © 2016 Giovanni Murru. All rights reserved.
//

#import "LBPHistogramsViewController.h"
#import "UIImage+OpenCV.h"
#import "FaceRecCommonTools.h"
#import "UIViewController+FaceRecTutorial.h"

@interface LBPHistogramsViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *myLabel;
@property (nonatomic) BOOL modelTraining;
@end

@implementation LBPHistogramsViewController


+(id)sharedLBPHistogramsViewController
{
    static LBPHistogramsViewController *sharedLBPHistogramsViewController = nil;
    @synchronized(self)
    {
        if (sharedLBPHistogramsViewController == nil)
        {
            sharedLBPHistogramsViewController = [[self alloc] init];
        }
    }
    return sharedLBPHistogramsViewController;
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


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    [self setTitle:@"LBPH"];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)runFaceDetectionAlgorithm:(const char *)csvPath
{
    
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
        [FaceRecCommonTools readCSV:fn_csv images:images labels:labels];
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
    int width = images[0].cols;
    int height = images[0].rows;
    
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
    
    CGFloat thumbsHeight = thumbsWidth * ((CGFloat)height/(CGFloat)width);
    // your dataset and remove it from the vector. This is
    // done, so that the training data (which we learn the
    // cv::LBPHFaceRecognizer on) and the test data we test
    // the model with, do not overlap.
    Mat testSample = images[images.size() - 1];
    int testLabel = labels[labels.size() - 1];
    images.pop_back();
    labels.pop_back();
    // The following lines create an LBPH model for
    // face recognition and train it with the images and
    // labels read from the given CSV file.
    //
    // The LBPHFaceRecognizer uses Extended Local Binary Patterns
    // (it's probably configurable with other operators at a later
    // point), and has the following default values
    //
    //      radius = 1
    //      neighbors = 8
    //      grid_x = 8
    //      grid_y = 8
    //
    // So if you want a LBPH FaceRecognizer using a radius of
    // 2 and 16 neighbors, call the factory method with:
    //
    //      cv::createLBPHFaceRecognizer(2, 16);
    //
    // And if you want a threshold (e.g. 123.0) call it with its default values:
    //
    //      cv::createLBPHFaceRecognizer(1,8,8,8,123.0)
    //
    cout << "Create LBPH Face Recognizer model" << endl;
    Ptr<LBPHFaceRecognizer> _model = createLBPHFaceRecognizer();
    
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
            
            [FaceRecCommonTools printFormattedTime:trainingTime];
            
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
            // First we'll use it to set the threshold of the LBPHFaceRecognizer
            // to 0.0 without retraining the model. This can be useful if
            // you are evaluating the model:
            //
            _model->setThreshold(0.0);
            // Now the threshold of this model is set to 0.0. A prediction
            // now returns -1, as it's impossible to have a distance below
            // it
            predictedLabel = _model->predict(testSample);
            cout << "Predicted class = " << predictedLabel << endl;
            // Show some informations about the model, as there's no cool
            // Model data to display as in Eigenfaces/Fisherfaces.
            // Due to efficiency reasons the LBP images are not stored
            // within the model:
            cout << "Model Information:" << endl;
            string model_info = format("\tLBPH(radius=%i, neighbors=%i, grid_x=%i, grid_y=%i, threshold=%.2f)",
                                       _model->getRadius(),
                                       _model->getNeighbors(),
                                       _model->getGridX(),
                                       _model->getGridY(),
                                       _model->getThreshold());
            cout << model_info << endl;
            // We could get the histograms for example:
            vector<Mat> histograms = _model->getHistograms();
            // But should I really visualize it? Probably the length is interesting:
            cout << "Size of the histograms: " << histograms[0].total() << endl;
            
            self.modelTraining = NO;
        });
    });
}

@end
