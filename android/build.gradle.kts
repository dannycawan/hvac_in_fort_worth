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

// 📌 Opsional: Custom build dir (hapus kalau bikin error di CI/CD)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    // Biasanya tidak perlu, hapus jika tidak ada dependency khusus
    // project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
