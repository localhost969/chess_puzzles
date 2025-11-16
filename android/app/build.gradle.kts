plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.chess_puzzles"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.chess_puzzles"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Restrict this build to Android 14 (API 34) only. Note: this will prevent installation
        // on devices with other Android versions. Consider fixing any Android 14 compatibility
        // issues instead of restricting the app in production.
        // Restrict this build to Android 14 (API 34) only. Note: this will prevent installation
        // on devices with other Android versions. Consider fixing compatibility instead of
        // restricting the app in production.
        minSdk = 34
        targetSdk = 34

        // NOTE: Avoid setting ndk.abiFilters here because the Gradle plugin or included plugins
        // may set their own configuration that conflicts with splits. For single-ABI builds,
        // prefer using `splits { abi { include("arm64-v8a") } }` or use the Flutter CLI
        // `--target-platform` switch.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // NOTE: Avoid configuring ABI splits here; some plugins or the Flutter Gradle plugin
    // set ABI filters automatically and this may conflict. Prefer using the Flutter CLI
    // to build for a single architecture: `flutter build apk --target-platform=android-arm64`.

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
