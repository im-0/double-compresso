import "../ci/just/all.inc.just"
import "../ci/just/conf.inc.just"
import "../ci/just/devcont-inside.inc.just"
import "../ci/just/dir-root-plus-1.inc.just"
import "../ci/just/dir-rust.inc.just"
import "../ci/just/common-rust.inc.just"

[doc("[D] Run Cargo with specified arguments")]
cargo *args:
    @cargo "${@}"

_fw-pico2w-bloat *args:
    DEFMT_LOG="info" cargo \
        bloat \
        --package "{{ fw_elf_name }}" \
        --profile "fw-release" \
        --target "thumbv8m.main-none-eabihf" \
        "${@}"

_fw-pico2w-build defmt profile:
    DEFMT_LOG="{{ defmt }}" cargo \
        build \
        --package "{{ fw_elf_name }}" \
        --profile "{{ profile }}" \
        --target "thumbv8m.main-none-eabihf"
    gmake \
        --file "../../../../ci/make/elf2uf2.mk" \
        --directory "target/thumbv8m.main-none-eabihf/{{ profile }}" \
        "{{ fw_elf_name }}.uf2"

_exe-build-linux profile package:
    cargo \
        build \
        --profile "{{ profile }}" \
        --package "{{ package }}"

_exe-build-windows profile package:
    cargo \
        build \
        --target "{{ rust_windows_target }}" \
        --profile "{{ profile }}" \
        --package "{{ package }}"

[doc("[D] Clean Rust subproject")]
rust-clean:
    cargo clean
