# This is included into justfiles outside of devcontainer.

cicli := "python3 -m cicli.main"
host_exe := if os() == "windows" { ".exe" } else { "" }
host_rust_target := if os() == "windows" { f"{{arch()}}-pc-windows-gnu/" } else { "" }
kotlin_dev_just := f"{{cicli}} --log-level \"warning\" devcmd --workdir \"kotlin\" -- just"
rust_dev_just := f"{{cicli}} --log-level \"warning\" devcmd --workdir \"rust\" -- just"

[doc("[D] Open shell or run a specified command inside devcontainer")]
[no-cd]
devsh *cmd:
    @{{ cicli }} \
        --log-level "warning" \
        devcmd \
        --workdir "" \
        {{ if cmd == "" { "--ignore-return-code -- bash --login" } else { "-- \"${@}\"" } }}
