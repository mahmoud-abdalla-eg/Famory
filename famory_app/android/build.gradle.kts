allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Keep Android outputs under the Flutter app's build directory so Flutter tooling
// can find generated APKs at the expected path.
val newBuildDir = rootProject.layout.projectDirectory.dir("../build")
rootProject.layout.buildDirectory.set(newBuildDir)

// Configure subprojects to use a specific build directory
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)  // Set the build directory for each subproject
}
