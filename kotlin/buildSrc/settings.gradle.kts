dependencyResolutionManagement {
    versionCatalogs {
        create("toolchain") {
            from(files("../gradle/toolchain.versions.toml"))
        }
        create("libs") {
            from(files("../gradle/libs.versions.toml"))
        }
    }
}
rootProject.name = ("buildSrc")
