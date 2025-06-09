plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ecom"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Updated NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.ecom"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file("../../upload-keystore.jks")
            storePassword = "12345678"
            keyAlias = "upload"
            keyPassword = "12345678"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")

            // Add ProGuard rules
            isShrinkResources = true
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android.txt"),
                "proguard-rules.pro"
            )
            
            // Disable R8 full mode if it's causing issues
            // This is optional - try with full mode first
            // enableR8FullMode = false
        }
    }
}

dependencies {
    // Add Play Core library
    implementation("com.google.android.play:core:1.10.3")
}

flutter {
    source = "../.."
}
