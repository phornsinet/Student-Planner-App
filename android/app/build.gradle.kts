plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // 1. Updated to 35 to fix the plugin warnings
    compileSdk = 35 
    ndkVersion = "27.0.12077973" 
    namespace = "com.example.student_planner_app"

    defaultConfig {
        applicationId = "com.example.student_planner_app"
        minSdk = 23 
        targetSdk = 35 
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }
}

flutter {
    source = "../.."
}

// 2. This block forces the JVM target to 1.8 to fix the "Target 21" error
tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
    kotlinOptions {
        jvmTarget = "1.8"
    }
}



