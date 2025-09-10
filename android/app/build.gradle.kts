plugins {
    id("com.android.application")
    id("kotlin-android")
}

android {
    namespace = "com.hvac.fortworth"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.hvac.fortworth"
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
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
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    implementation("com.google.android.gms:play-services-ads:23.1.0")
}