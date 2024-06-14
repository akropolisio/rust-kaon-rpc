#!/usr/bin/env bash
#
# Run the integration test optionally downloading Kaon Core binary if KAONVERSION is set.

set -euo pipefail

REPO_DIR=$(git rev-parse --show-toplevel)

# Make all cargo invocations verbose.
export CARGO_TERM_VERBOSE=true

main() {
    # If a specific version of Kaon Core is set then download the binary.
    if [ -n "${KAONVERSION+x}" ]; then
        download_binary
    fi

    need_cmd kaond

    cd integration_test
    ./run.sh
}

download_binary() {
    # TODO: place bin
    wget https://kaon.one/bin/kaon-core-$KAONVERSION/kaon-$KAONVERSION-x86_64-linux-gnu.tar.gz
    tar -xzvf kaon-$KAONVERSION-x86_64-linux-gnu.tar.gz
    export PATH=$PATH:$(pwd)/kaon-$KAONVERSION/bin
}

err() {
    echo "$1" >&2
    exit 1
}

need_cmd() {
    if ! command -v "$1" > /dev/null 2>&1
    then err "need '$1' (command not found)"
    fi
}

#
# Main script
#
main "$@"
exit 0
