# FACameraView

[![CI Status](http://img.shields.io/travis/fadizant/FACameraView.svg?style=flat)](https://travis-ci.org/fadizant/FACameraView)
[![Version](https://img.shields.io/cocoapods/v/FACameraView.svg?style=flat)](http://cocoapods.org/pods/FACameraView)
[![License](https://img.shields.io/cocoapods/l/FACameraView.svg?style=flat)](http://cocoapods.org/pods/FACameraView)
[![Platform](https://img.shields.io/cocoapods/p/FACameraView.svg?style=flat)](http://cocoapods.org/pods/FACameraView)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

<img src="http://www.m5zn.com/newuploads/2017/09/22/gif//f7b4771239038d3.gif"/>
<br>
<img src="http://www.m5zn.com/newuploads/2017/09/22/gif//9f74ffe7685c876.gif"/>
<br>
<img src="http://www.m5zn.com/newuploads/2017/09/22/gif//31296306bf8a700.gif"/>
<br>

```ruby
    CameraViewController *cam = [CameraViewController new];
    cam.max = 3;//maximum number of images
    cam.didDismiss = ^void(NSMutableArray<FAImageLibraryItem*>* images)
    {
        //your code here
    };
    
    [self presentViewController:cam animated:YES completion:^{
    }];
```

## Requirements

## Installation

FACameraView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FACameraView'
```

## Author

fadizant, fadizant@hotmail.com

## License

FACameraView is available under the MIT license. See the LICENSE file for more info.
