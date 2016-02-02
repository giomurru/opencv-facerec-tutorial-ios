# Face Recognition OpenCV Tutorial

This project is an iOS porting of the tutorial available in the [OpenCV docs](http://docs.opencv.org/2.4/modules/contrib/doc/facerec/facerec_tutorial.html#face-recognition-with-opencv)

Before using this project you need to copy the OpenCV framework with contrib modules `opencv2.framework` inside the root folder of this project

You can download the OpenCV framework with contrib modules here:
http://gmurru.altervista.org/public/libraries/iOS/opencv/opencv-3.1-with-contrib.zip

Alternatively, you can build it following these instructions:

1. Clone OpenCV 3.1.0: 
```
git clone --branch 3.1.0 https://github.com/Itseez/opencv.git
```
2. Clone OpenCV Contrib:
```
git clone --branch 3.1.0 https://github.com/Itseez/opencv_contrib.git
```
3. Create a copy of OpenCV 3.1.0 folder (the one you cloned in 1.) and name it `opencv-3.1.0-with-contrib`
```
cp -r opencv opencv-3.1.0-with-contrib
```
4. Copy the content of the `modules` folder of OpenCV Contrib (the one you cloned in 2.) inside the `modules` folder of `opencv-3.1.0-with-contrib` (the one you created in 3.). Now you can delete the folders you created in steps 1. and 2.
```
cp -r opencv_contrib/modules/* opencv-3.1.0-with-contrib/modules/
```
6. Create a directory to save the framework:
```
mkdir opencv-ios-contrib
```
7. Build the framework:
```
python opencv-3.1.0-with-contrib/platforms/ios/build_framework.py opencv-ios-contrib
```
8. Wait the build process to finish. Once you generated the framework using the commands above, please copy the generated opencv2.framework in the root folder of this project.
