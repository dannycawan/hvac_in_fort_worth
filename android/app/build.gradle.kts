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
    ndkVersion = "27.0.12077973" // opsional

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
        vectorDrawables.useSupportLibrary = true
    }

    // 🔑 Load key.properties
    val keystorePropertiesFile: File = rootProject.file("android/key.properties")
    val keystoreProperties = Properties()
    if (keystorePropertiesFile.exists()) {
        println("✅ key.properties ditemukan: ${keystorePropertiesFile.absolutePath}")
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    } else {
        println("⚠️ WARNING: key.properties tidak ditemukan!")
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"]?.toString()
            keyPassword = keystoreProperties["keyPassword"]?.toString()
            val storeFilePath = keystoreProperties["storeFile"]?.toString()
            if (!storeFilePath.isNullOrEmpty()) {
                println("✅ Menggunakan storeFile path: $storeFilePath")
                storeFile = file(storeFilePath) // relatif ke root project
            } else {
                println("⚠️ ERROR: storeFile tidak ada di key.properties")
            }
            storePassword = keystoreProperties["storePassword"]?.toString()
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
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
            excludes += setOf("META-INF/LICENSE*", "META-INF/NOTICE*")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.android.gms:play-services-ads:23.1.0")
}
