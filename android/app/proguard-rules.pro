## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## Firebase
-keep class com.google.firebase.** { *; }

## Razorpay fix
-keep class com.razorpay.** { *; }
-keepclassmembers class com.razorpay.** { *; }

## Flutter engine
-dontwarn io.flutter.embedding.**
-ignorewarnings
