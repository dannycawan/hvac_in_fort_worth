pluginManagement {
    // Ambil path Flutter SDK dari local.properties jika ada
    val flutterSdkPath = runCatching {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        properties.getProperty("flutter.sdk")
    }.getOrNull()

    if (flutterSdkPath != null) {
        includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
    }

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.1.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.10" apply false
}

rootProject.name = "hvac_in_fortworth"
include(":app")
