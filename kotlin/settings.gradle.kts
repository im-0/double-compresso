pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}

dependencyResolutionManagement {
    versionCatalogs {
        create("toolchain") {
            from(files("gradle/toolchain.versions.toml"))
        }
    }
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = ("doublecompresso")

enableFeaturePreview("TYPESAFE_PROJECT_ACCESSORS")

include(
    "app",
    "library-android",
    "library-compose",
    "library-kotlin"
)
