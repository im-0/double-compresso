# This is included into all justfiles where devcontainer Rust recipes must be available.

[doc("[D] Run Cargo with specified arguments")]
[group("Rust (firmware, CLI and GUI development) tools")]
cargo *args:
    @{{ rust_dev_just }} cargo "${@}"

_fw-pico2w-bloat *args:
    @{{ rust_dev_just }} _fw-pico2w-bloat "${@}"

_fw-pico2w-build defmt profile:
    @{{ rust_dev_just }} _fw-pico2w-build "{{ defmt }}" "{{ profile }}"

_exe-build-linux profile package:
    @{{ rust_dev_just }} _exe-build-linux "{{ profile }}" "{{ package }}"

_exe-build-windows profile package:
    @{{ rust_dev_just }} _exe-build-windows "{{ profile }}" "{{ package }}"

[doc("[D] Clean Rust subproject")]
[group("Rust (firmware, CLI and GUI development) tools")]
rust-clean:
    @{{ rust_dev_just }} rust-clean
