plugins {
    id("com.android.application")
    id("kotlin-android")

    // ✅ Firebase Google Services plugin eklendi
    id("com.google.gms.google-services")

    // Flutter Gradle Plugin en sonda olmalı
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.plantistapp.plantist_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.plantistapp.plantist_app"

        // ✅ Firebase eklentileri için minimum 23 gerekiyor
        minSdk = 23
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Debug imzası ile release derlemesi yapılabilir
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
