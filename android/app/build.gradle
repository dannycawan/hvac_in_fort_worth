plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin harus terakhir
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.hvac.fortworth"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // pakai versi terbaru sesuai kebutuhan dependency

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.hvac.fortworth"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // opsional: agar tidak crash karena WebView di Android 11+
        vectorDrawables.useSupportLibrary = true
    }

    signingConfigs {
        // Load key.properties (jika ada)
        def keystorePropertiesFile = rootProject.file("android/key.properties")
        if (keystorePropertiesFile.exists()) {
            def keystoreProperties = new Properties()
            keystoreProperties.load(new FileInputStream(keystorePropertiesFile))

            create("release") {
                storeFile = file(keystoreProperties["storeFile"])
                storePassword = keystoreProperties["storePassword"]
                keyAlias = keystoreProperties["keyAlias"]
                keyPassword = keystoreProperties["keyPassword"]
            }
        }
    }

    buildTypes {
        release {
            // Pakai release keystore kalau tersedia, kalau tidak fallback ke debug
            signingConfig = signingConfigs.findByName("release") ?: signingConfigs.getByName("debug")

            // sementara biar build cepat & stabil
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            // opsional, supaya debug lebih gampang
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
