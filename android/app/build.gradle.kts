plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin
    id("dev.flutter.flutter-gradle-plugin")
    // Google Services plugin (dibutuhkan untuk AdMob)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.hvac.fortworth" // ganti sesuai package name di AndroidManifest
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
        applicationId = "com.hvac.fortworth" // pastikan sama dengan AndroidManifest
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: kalau sudah siap ke Play Store, buat signingConfig sendiri
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.android.gms:play-services-ads:23.1.0") // AdMob SDK
}
