import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle Plugin harus terakhir
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.hvac.fortworth"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // opsional, sesuai kebutuhan dependency

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

        // Agar tidak crash karena WebView di Android 11+
        vectorDrawables.useSupportLibrary = true
    }

    // 🔑 Load key.properties
    val keystorePropertiesFile: File = rootProject.file("android/key.properties")
    val keystoreProperties = Properties()
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"]?.toString()
            keyPassword = keystoreProperties["keyPassword"]?.toString()
            val storeFilePath = keystoreProperties["storeFile"]?.toString()
            if (!storeFilePath.isNullOrEmpty()) {
                // ✅ path selalu relatif terhadap root project
                storeFile = rootProject.file("android/$storeFilePath")
            }
            storePassword = keystoreProperties["storePassword"]?.toString()
        }
    }

    buildTypes {
        release {
            // ✅ pakai keystore release (bukan debug)
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            // hanya untuk development/testing
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
