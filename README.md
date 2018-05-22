# Tracer

[![Build Status](https://travis-ci.com/KeepSafe/Tracer-iOS.svg?token=FkPqyrwwnAY4pErzdxwy&branch=master)](https://travis-ci.com/KeepSafe/Tracer-iOS)
[![Apache 2.0 licensed](https://img.shields.io/badge/license-Apache2-blue.svg)](https://github.com/KeepSafe/Tracer-iOS/blob/master/LICENSE)
[![CocoaPods](https://img.shields.io/cocoapods/v/Tracer.svg?maxAge=10800)]()
[![Swift 4+](https://img.shields.io/badge/language-Swift-blue.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/OS-iOS-orange.svg)](https://developer.apple.com/ios/)

## What it does

Tracer acts as an in-memory log which can run time-scoped traces to validate UX flows, analytic events, or any other kind of serial event bus.

For example, if you're expecting `EventOne`, `EventTwo` and `EventThree` to be fired during a sign-up flow, Tracer can help your development or QA team validate those analytics don't break at some point. 

Anything that can be represented as `Equatable` can be logged and validated during a trace. Common examples of this would be strings, arrays or dictionaries (especially with [conditional conformance in Swift 4.1](https://swift.org/blog/conditional-conformance)) but you can also pass in your own custom structs or classes as long as they are `Equatable`.

You can either run the traces manually, using the built-in UI that floats over top of your app, or have important traces run automatically during unit or UI tests.

### Example UI Usage

See [example gifs](#examples) below or see the [Examples folder](https://github.com/KeepSafe/Tracer-iOS/tree/master/Examples) for demonstrations of using it. 

### API Usage

Or jump into the [API section](#api) below if you're ready to implement.

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

## Examples

### Running a trace

After you tell the trace tool about your traces, it will list them all and enable you or your QA team to start one manually.

Here's a simple example of a trace where order matters:

![passinginorder](https://user-images.githubusercontent.com/30269720/40362283-169dca86-5d9a-11e8-8995-7bf89d714cf4.gif)

And here's the same trace failing when an event is fired out of order (in this case, it fails all events before it that haven't already been matched since they would also be considered out-of-order).

![failingoutoforder](https://user-images.githubusercontent.com/30269720/40362347-411b9496-5d9a-11e8-9e95-a1ff75341fcc.gif)

### Move it around

You can expand or collapse the UI at any time, or even move it around the screen or drag the top of it to resize how much screen real estate it covers when expanded.

![moveitaround](https://user-images.githubusercontent.com/30269720/40361667-1bcb4bac-5d98-11e8-817d-f4d480d155b4.gif)


### Logger

Logging uses the `debugDescription` of each item to display it on screen, so be sure your more complex data structures implement this for how you'd like to show it.

![tracetool](https://user-images.githubusercontent.com/30269720/40361723-500a802c-5d98-11e8-80f0-ca5c409d3b05.png)

### Traces

[Traces](https://github.com/KeepSafe/Tracer-iOS/blob/master/Source/Traces/Trace.swift) have multiple options like `enforceOrder`, `allowDuplicates` or `assertOnFailure` that you can configure for specific scenarios. You can even perform programmatic setup steps (like resetting your app to a certain configuration) before each trace is started or list optional setup steps for someone to do so manually.

#### Example 1: Order matters, duplicates don't

![configone](https://user-images.githubusercontent.com/30269720/40362198-d44b552c-5d99-11e8-9eca-8ac659cfb3d3.png)

(passing/failing this trace was shown in the first example section above)

#### Example 2: No duplicates, order doesn't matter

![configtwo](https://user-images.githubusercontent.com/30269720/40362231-e8814a56-5d99-11e8-974c-82f2d032907e.png)

Order doesn't matter for this trace, so passing it would look like:

![passingoutoforder](https://user-images.githubusercontent.com/30269720/40362419-7f3da3cc-5d9a-11e8-9545-f40b4b664eb3.gif)

**But**, duplicates do matter so if we fired any during the trace it would fail:

![failingduplicate](https://user-images.githubusercontent.com/30269720/40362470-a16644a4-5d9a-11e8-8fe4-57e8b2c51469.gif)

### Custom Settings

Optionally, you can also add your own custom settings to the trace tool (or even show custom emojis for a logged item):

![customsettings](https://user-images.githubusercontent.com/30269720/40362532-c42227a6-5d9a-11e8-8bed-a7358bbef5ea.gif)

## API

### UI

If you're using the UI frontend, you'll be interacting directly through [TraceUI.swift](https://github.com/KeepSafe/Tracer-iOS/blob/master/UI/TraceUI.swift). See the [TraceUIExample](https://github.com/KeepSafe/Tracer-iOS/tree/master/Examples/TraceUIExample).

```swift
let traceUI = TraceUI()
traceUI.show()
```

You can also toggle this to `.hide()` via a debug setting if you'd like.

> **Note**: If you're starting this tool in your `AppDelegate`, you should lazily load it after your app window loads to ensure the tool starts properly. The best thing to do is listen for `.UIWindowDidBecomeKey` and only show it after that happens.

#### Configuration

Load traces into the UI using:

```swift
traceUI.add(traces: [MyTraces.traceOne, MyTraces.traceTwo])
```

#### Logging & Validation

If you're logging an item specifically to be validated against for a trace, use:

```swift
traceUI.log(traceItem: Event.three.toTraceItem)
```

Here we're just creating an `Event` enum with the events we're firing within the app and then using the `.toTraceItem` property to transform it:

```swift
enum Event: String {
    case one
    case two
    case three
    
    var uxFlowHint: String {
        switch self {
        case .one: return "Press the 'Fire event 1' button"
        case .two: return "Press the 'Fire event 2' button"
        case .three: return "Press the 'Fire event 3' button"
        }
    }
    
    var toTraceItem: TraceItem {
        return TraceItem(type: "event", itemToMatch: AnyTraceEquatable(self), uxFlowHint: uxFlowHint)
    }
}
````

Otherwise, you can also generically log (without it validating against an ongoing trace) by using:

```swift
traceUI.log(genericItem: AnyTraceEquatable("Moooooooooo"), emojiToPrepend: "🐄")
```

#### All Logging

You can see all logging functions and their documentation in [TraceUI.swift]():

```swift
public func log(traceItem: TraceItem, verboseLog: AnyTraceEquatable? = nil, emojiToPrepend: String? = "⚡️") {}

public func logVerbose(traceItem: TraceItem, emojiToPrepend: String? = "⚡️") { }

public func log(genericItem: AnyTraceEquatable, properties: LoggedItemProperties? = nil, emojiToPrepend: String? = "⚡️") { }
```

### Programmatic API

If you'd rather not use the built-in UI frontend, you can set up your traces to run manually, such as during unit or UI tests. See the [AnalyticsTraceExample](https://github.com/KeepSafe/Tracer-iOS/tree/master/Examples/AnalyticsTraceExample).

Feel free to have a look through the [unit tests](https://github.com/KeepSafe/Tracer-iOS/tree/master/TracerTests) for examples.

#### Creating and starting a trace

```swift
// This is an individual item to match and could be in multiple traces
let answerTraceItem = TraceItem(type: "The answer to the universe", itemToMatch: AnyTraceEquatable(42))
// This is a trace with an array of items it needs to match in order to pass
let trace = Trace(name: "Find the answer", itemsToMatch: [answerTraceItem])
// And this is the time-scoped tracer that handles logging and creating pass/fail results
let tracer = Tracer(trace: trace)

// Starting a trace returns a tuple with the current state and two signals to listen to
let (currentState, stateChangedSignal, itemLoggedSignal) = tracer.start()

print("\n\n---> TRACE STARTED: \(analyticsTrace.name)")
print("---> Current trace state: \(currentState)")

// Optionally, listen to changes in this trace (and you can remove the listener at any point)
itemLoggedListener = itemLoggedSignal.listen { traceItem in
    print("---> Trace item logged: \(traceItem)")
}
stateChangedListener = stateChangedSignal.listen { traceState in
    print("---> Trace state updated to: \(traceState.rawValue)")
    print("---> Trace state description: \(traceState)")
}
```

#### Logging

Logging during a trace is simple:

```swift
tracer.log(item: answerTraceItem)

// After an item is logged, your trace will immediately either be passing or failing.
// Optionally, you can set `assertOnFailure` to `true` on your `Trace` instance to stop 
// app execution as soon as a trace fails so you can debug.
```

Or you can even hook it into your `Analytics` struct:

```swift
Analytics.log(event: .thirdViewSeen)

/// See example app for this setup
struct Analytics {
    
    static func log(event: AnalyticsEvent) {
        print("\n\nANALYTICS: \(event.rawValue) logged")
        
        Tracers.analytics.activeTracer?.log(item: event.toTraceItem)
    }
    
}
```

#### Stopping & Reporting

Stopping a trace returns a `TraceReport` with raw or summary versions of the results

```swift
// FYI: signal listeners are automatically removed when stopped
let report = tracer.stop()
print(report.summary)
print(report.rawLog)

// Or manually parse the results yourself
let results = report.result
```

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
