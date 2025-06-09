# Handling missing ProGuard annotations
-dontwarn proguard.annotation.**

# Keep Razorpay classes
-keep class com.razorpay.** { *; }
-keepclassmembers class com.razorpay.** { *; }

# Ignore missing Google Pay API classes
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.**

# Ignore missing Play Core API classes
-dontwarn com.google.android.play.core.**

# Common Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep all classes that might be used in reflection
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
