plugins {
    // Android Gradle Plugin → jangan lock version di sini
    id("com.android.application") apply false

    // Kotlin Android → pakai versi bawaan Flutter SDK
    id("org.jetbrains.kotlin.android") apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
