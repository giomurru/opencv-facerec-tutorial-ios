# Face Recognition OpenCV Tutorial

This project is an iOS porting of the tutorial available in the [OpenCV docs](http://docs.opencv.org/2.4/modules/contrib/doc/facerec/facerec_tutorial.html#face-recognition-with-opencv)

Before using this project you need to copy the OpenCV framework with contrib modules `opencv2.framework` inside the root folder of this project

You can build it following these instructions:

* Clone `OpenCV 3.2.0`: 
```
git clone -b 3.2.0 --single-branch https://github.com/opencv/opencv.git
```
* Clone `OpenCV Contrib`:
```
git clone -b 3.2.0 --single-branch https://github.com/opencv/opencv_contrib.git
```
* Create a copy of `OpenCV 3.2.0` folder and name it `opencv-3.2.0-with-contrib`
```
cp -r opencv opencv-3.2.0-with-contrib
```
* Copy the content of the `modules` folder of `OpenCV Contrib` inside the `modules` folder of `opencv-3.2.0-with-contrib`
```
cp -r opencv_contrib/modules/* opencv-3.2.0-with-contrib/modules/
```
* Create a directory to save the framework:
```
mkdir opencv-ios-contrib
```
* Build the framework and save it inside `opencv-ios-contrib` folder:
```
python opencv-3.2.0-with-contrib/platforms/ios/build_framework.py opencv-ios-contrib
```
* Wait the build process to complete. Once you generated the framework using the commands above, please copy the generated opencv2.framework in the root folder of this project.
* I had cmake problem that I was not able to solve with xfeatures2d. If you have the same problem just delete the module xfeatures2d and the build process should succesfully complete.
