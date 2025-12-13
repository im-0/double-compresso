# This is included into justfiles outside of devcontainer.

cicli := "python3 -m cicli.main --inside-devcontainer"

_devcontainer-post-start-command:
    rsync \
        --recursive \
        --update \
        --delete \
        --itemize-changes \
        --executability \
        --times \
        "/opt/host-tools/" \
        "{{ src_root_dir }}/.host-tools"
