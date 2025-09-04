plugins {
    // Android Gradle Plugin
    id("com.android.application") version "8.7.3" apply false
    // Kotlin Android
    kotlin("android") version "1.9.25" apply false
    // Tidak pakai Firebase → google-services tidak perlu
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Custom build dir biar lebih rapi
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
