# This is included into all justfiles where devcontainer Kotlin recipes must be available.

[doc("[D] Run Gradle with specified arguments")]
[group("Kotlin (Android development) tools")]
gradle *args:
    @{{ kotlin_dev_just }} gradle "${@}"

[doc("[D] Run ADB with specified arguments")]
[group("Android application")]
adb *args:
    @{{ kotlin_dev_just }} adb "${@}"

[doc("[D] Run ADB Enhanced with specified arguments")]
[group("Android application")]
adbe *args:
    @{{ kotlin_dev_just }} adbe "${@}"

[doc("[D] Disconnect ADB from all Android devices")]
[group("Android application")]
adb-disconnect-all:
    @{{ kotlin_dev_just }} adb-disconnect-all

[doc("[D] Run debug Android APK using ADB over network")]
[group("Android application")]
apk:
    @{{ kotlin_dev_just }} apk

_apk-build:
    @{{ kotlin_dev_just }} _apk-build

[doc("[D] Run release Android APK using ADB over network")]
[group("Android application")]
apk-release:
    @{{ kotlin_dev_just }} apk-release

_apk-build-release:
    @{{ kotlin_dev_just }} _apk-build-release

[doc("[D] Clean Kotlin/Android subproject")]
[group("Kotlin (Android development) tools")]
kotlin-clean:
    @{{ kotlin_dev_just }} kotlin-clean
