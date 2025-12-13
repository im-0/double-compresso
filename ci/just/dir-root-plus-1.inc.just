# This is included into ${SOURCE_ROOT}/*/ justfiles.

export PYTHONPATH := justfile_directory() + "/../ci" + if env("PYTHONPATH", "") == "" { "" } else { ":" + env("PYTHONPATH") }
src_root_dir := ".."
