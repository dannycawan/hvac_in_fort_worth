import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter plugin harus terakhir
}

android {
    namespace = "com.hvac.fortworth"
    compileSdk = flutter.compileSdkVersion

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
            storeFile = keystoreProperties["storeFile"]?.toString()?.let { file(it) }
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
