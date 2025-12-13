# This is included into all justfiles outside the devcontainer where Rust recipes must be available.

defmt_log_format := "oneline"

[doc("[/] Run debug firmware")]
[group("Firmware for Raspberry Pi Pico 2 W")]
fw-pico2w: fw-pico2w-build
    "{{ src_root_dir }}/.host-tools/probe-rs{{ host_exe }}" \
        run \
        --chip "RP235x" \
        --protocol "swd" \
        --preverify \
        --verify \
        --always-print-stacktrace \
        --log-format "{{ defmt_log_format }}" \
        "{{ rust_dir }}/target/thumbv8m.main-none-eabihf/fw-debug/{{ fw_elf_name }}"

[doc("[/] Attach to μC running debug firmware")]
[group("Firmware for Raspberry Pi Pico 2 W")]
fw-pico2w-attach:
    "{{ src_root_dir }}/.host-tools/probe-rs{{ host_exe }}" \
        attach \
        --chip "RP235x" \
        --protocol "swd" \
        --always-print-stacktrace \
        --log-format "{{ defmt_log_format }}" \
        "{{ rust_dir }}/target/thumbv8m.main-none-eabihf/fw-debug/{{ fw_elf_name }}"

[doc("[/] Run release firmware")]
[group("Firmware for Raspberry Pi Pico 2 W")]
fw-pico2w-release: fw-pico2w-build-release
    "{{ src_root_dir }}/.host-tools/probe-rs{{ host_exe }}" \
        run \
        --chip "RP235x" \
        --protocol "swd" \
        --preverify \
        --verify \
        --always-print-stacktrace \
        --log-format "{{ defmt_log_format }}" \
        "{{ rust_dir }}/target/thumbv8m.main-none-eabihf/fw-release/{{ fw_elf_name }}"

[doc("[/] Attach to μC running release firmware")]
[group("Firmware for Raspberry Pi Pico 2 W")]
fw-pico2w-attach-release:
    "{{ src_root_dir }}/.host-tools/probe-rs{{ host_exe }}" \
        attach \
        --chip "RP235x" \
        --protocol "swd" \
        --always-print-stacktrace \
        --log-format "{{ defmt_log_format }}" \
        "{{ rust_dir }}/target/thumbv8m.main-none-eabihf/fw-release/{{ fw_elf_name }}"

[doc("[/] Run debug CLI application")]
[group("CLI application")]
cli *args: cli-build
    {{ rust_dir }}/target/{{ host_rust_target }}debug/{{ cli_bin_name }}{{ host_exe }} "${@}"

[doc("[/] Run release CLI application")]
[group("CLI application")]
cli-release *args: cli-build-release
    {{ rust_dir }}/target/{{ host_rust_target }}release/{{ cli_bin_name }}{{ host_exe }} "${@}"

[doc("[/] Build debug CLI application for host OS")]
[group("CLI application")]
cli-build: _cli-build

[doc("[/] Build release CLI application for host OS")]
[group("CLI application")]
cli-build-release: _cli-build-release

[linux]
_cli-build: cli-build-linux

[linux]
_cli-build-release: cli-build-linux-release

[windows]
_cli-build: cli-build-windows

[windows]
_cli-build-release: cli-build-windows-release

[doc("[/] Run debug GUI application")]
[group("GUI application")]
gui *args: gui-build
    {{ rust_dir }}/target/{{ host_rust_target }}debug/{{ gui_bin_name }}{{ host_exe }} "${@}"

[doc("[/] Run release GUI application")]
[group("GUI application")]
gui-release *args: gui-build-release
    {{ rust_dir }}/target/{{ host_rust_target }}release/{{ gui_bin_name }}{{ host_exe }} "${@}"

[doc("[/] Build debug GUI application for host OS")]
[group("GUI application")]
gui-build: _gui-build

[doc("[/] Build release GUI application for host OS")]
[group("GUI application")]
gui-build-release: _gui-build-release

[linux]
_gui-build: gui-build-linux

[linux]
_gui-build-release: gui-build-linux-release

[windows]
_gui-build: gui-build-windows

[windows]
_gui-build-release: gui-build-windows-release
