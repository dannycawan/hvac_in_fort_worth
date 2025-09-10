plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin harus terakhir
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.hvac.fortworth"
    compileSdk = 35
    ndkVersion = "27.0.12077973" // sesuai kebutuhan dependency

    defaultConfig {
        applicationId = "com.hvac.fortworth"
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
        vectorDrawables.useSupportLibrary = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // ganti dengan release signing sebelum upload
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "-debug"
        }
    }

    packaging {
        resources {
            excludes += setOf(
                "META-INF/LICENSE*",
                "META-INF/NOTICE*"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // AdMob SDK
    implementation("com.google.android.gms:play-services-ads:23.1.0")
}
