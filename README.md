# Tracer

[![Build Status](https://travis-ci.com/KeepSafe/Tracer-iOS.svg?token=FkPqyrwwnAY4pErzdxwy&branch=master)](https://travis-ci.com/KeepSafe/Tracer-iOS)
[![Apache 2.0 licensed](https://img.shields.io/badge/license-Apache2-blue.svg)](https://github.com/KeepSafe/Tracer-iOS/blob/master/LICENSE)
[![CocoaPods](https://img.shields.io/cocoapods/v/Tracer.svg?maxAge=10800)]()
[![Swift 4+](https://img.shields.io/badge/language-Swift-blue.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/OS-iOS-orange.svg)](https://developer.apple.com/ios/)

## What it does

Tracer acts as an in-memory log which can run time-scoped traces to validate UX flows, analytic events, or any other kind of serial event bus.

For example, if you're expecting `EventOne`, `EventTwo` and `EventThree` to be fired during a sign-up flow, Tracer can help your development or QA team validate those analytics don't break at some point. 

You can either run the traces manually, using the built-in UI that floats over top of your app, or have important traces run automatically during unit or UI tests.

See [example gifs](#examples) below or see the [Examples folder](https://github.com/KeepSafe/Tracer-iOS/tree/master/Examples) for demonstrations of using it. 

## Installation

Quickly install using [CocoaPods](https://cocoapods.org): 

```ruby
pod 'Tracer/UI'

# or optionally don't include the UI component
pod 'Tracer/Core'
```

Or [Carthage](https://github.com/Carthage/Carthage):

```
github "KeepSafe/Tracer-iOS"
```

Or [manually install it](#manual-installation)

## Example Usage

Coming soon...

## Manual Installation

1. Clone this repository and drag the `Tracer.xcodeproj` into the Project Navigator of your application's Xcode project.
  - It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.
2. Select the `Tracer.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
3. Select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the `Targets` heading in the sidebar.
4. In the tab bar at the top of that window, open the `General` panel.
5. Click on the `+` button under the `Embedded Binaries` section.
6. Search for and select the top `Tracer.framework`.

And that's it!

The `Tracer.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

## Issues & Bugs

Please use the [Github issue tracker](https://github.com/KeepSafe/Tracer-iOS/issues) to let us know about any issues you may be experiencing.

## License

Tracer for iOS is licensed under the [Apache Software License, 2.0 ("Apache 2.0")](https://github.com/KeepSafe/Tracer-iOS/blob/master/LICENSE)

## Authors

Tracer for iOS is brought to you by [Rob Phillips](https://github.com/iwasrobbed) and the rest of the [Keepsafe team](https://www.getkeepsafe.com/about.html). We'd love to have you contribute or [join us](https://www.getkeepsafe.com/careers.html).
