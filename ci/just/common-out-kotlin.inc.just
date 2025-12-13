# This is included into all justfiles outside the devcontainer where Kotlin recipes must be available.

[doc("[/] Enable ADB over network on Android device connected via USB")]
[group("Android application")]
adb-enable-remote port="5555":
    -adb attach
    adb devices -l
    adb shell getprop ro.product.model
    adb shell ip -4 address
    adb tcpip {{ port }}
    sleep 1
    adb wait-for-device
    adb detach
