allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Define the new build directory for the root project
val newBuildDir = rootProject.layout.projectDirectory.dir("../../build")
rootProject.layout.buildDirectory.set(newBuildDir)

// Configure subprojects to use a specific build directory
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)  // Set the build directory for each subproject
}