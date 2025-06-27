# Matrix chat app
This app is a sample on how you can use [matrix](https://matrix.org) in your app for open source chat.

It's a simplified version so it's beginner friendly.

## How to use this app
Simply clone/download this app and open `MatrixSiv.xcodeproj`. Then, run the application and you're done

```
💡 If you're getting errors when running, try resetting package caches or resolving package versions then clean the build folder before running
```

## How to use matrix on your own app
1. Create your app
2. Install [MatrixRustSDK](https://github.com/matrix-org/matrix-rust-components-swift/) package in SPM
    1. Open your project file in XCode
    2. In `Package Dependencies` add `https://github.com/matrix-org/matrix-rust-components-swift/`. This app uses up to next major version from verison 25.4.16 but you may use other versions. However, the sample app might be 100% compatible with your version.

3. Use this app as a basis for using Matrix on your app.

``` 
💡 You have to set up your own matrix appservice to have your own homeserver and to register users.
```