# Development

## Dependencies

### Linux

```bash
#
# Fedora
#

# To build all kinds of binaries:
sudo dnf install git just podman
# To run firmware on real hardware:
sudo dnf install libusb1
# To run Android APK on real phone:
sudo dnf install android-tools
```

Note that `probe-rs` is required to work with firmware on real hardware and it may require additional setup,
see https://probe.rs/docs/getting-started/probe-setup/ for details.

## Commands

Most of the things are done inside the Development Container. Some tasks require hardware access (USB or Bluetooth),
so they are run various binaries outside the container.

For simplicity, we use the `just` tool to run typical tasks, including starting the development container if needed:

```bash
# Show available commands:
just

# Open shell inside the development container:
just devsh

# Run a shell command inside the development container:
just devsh ls -lah
```

### How to...

Update Gradle wrapper to a latest version:

```bash
just gradle wrapper --gradle-version "latest"
just gradle wrapper
```

Make `waydroid` window smaller:

```bash
waydroid prop set persist.waydroid.height 1800
waydroid prop set persist.waydroid.width 800
```

## Links

### Hardware

OLED used in prototype:

* https://www.waveshare.com/wiki/1.3inch_OLED_HAT
* https://files.waveshare.com/upload/c/c8/1.3inch-OLED-HAL-Schematic.pdf
