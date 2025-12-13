# This is included into all justfiles where Kotlin recipes must be available.

[doc("[D] Build debug Android APK")]
[group("Android application")]
apk-build: _apk-build
    @echo
    @echo "Debug APK:"
    @ls -lh {{ kotlin_dir }}/app/build/outputs/apk/debug/*.apk
    @echo

[doc("[D] Build release Android APK")]
[group("Android application")]
apk-build-release: _apk-build-release
    @echo
    @echo "Release APK:"
    @ls -lh {{ kotlin_dir }}/app/build/outputs/apk/release/*.apk
    @echo
