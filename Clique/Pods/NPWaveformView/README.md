# NPWaveformView

[![Version](https://img.shields.io/cocoapods/v/NPWaveformView.svg?style=flat)](http://cocoapods.org/pods/NPWaveformView)
[![License](https://img.shields.io/cocoapods/l/NPWaveformView.svg?style=flat)](http://cocoapods.org/pods/NPWaveformView)
[![Platform](https://img.shields.io/cocoapods/p/NPWaveformView.svg?style=flat)](http://cocoapods.org/pods/NPWaveformView)

NPWaveformView is an UIView fully customizable subclass that reproduces the waveform effect seen in Siri.

![](http://s13.postimg.org/dil5puf0n/Untitled_1.jpg =300x300)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
* iOS 8+
* Xcode 7.0+

## Installation
### CocoaPods
Add the NPWaveformView pod into your project and run `pod install`
```ruby
pod 'NPWaveformView'
```
### Manual Install
Download NPWaveformView and import `NPWaveformView.swift` inside your xcode project.

## Sample App
To start using NPWaveformView you can build the provided example project

1. Open `Example/NPWaveformView.xcodeproj` in Xcode.
2. Build and run.

## Usage
Import NPWaveformView in your Swift code:
```swift
import NPWaveformView
```

### Interface Builder
Add an UIView with interface builder and set `NPWaveformView` as UIView custom class.

Link it with the outlet property declared in your code.

```swift
@IBOutlet weak var waveformView: NPWaveformView!
```
## Customization
These are the customizable properties:

*  UIColor `waveColor`
*  Int `numberOfWaves`
*  CGFLoat `primaryWaveLineWidth`
*  CGFloat `secondaryWaveLineWidth`
*  CGFloat `idleAmplitude`
*  CGFloat `frequency`
*  CGFloat `density`
*  CGFloat `phaseShift`
*  CGFloat `amplitude`


## Author

Nicola Perantoni, nicola.perantoni@gmail.com

## License

NPWaveformView is available under the MIT license. See the LICENSE file for more info.
