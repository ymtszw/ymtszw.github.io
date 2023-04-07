#!/usr/bin/env bash
set -euo pipefail

# Set OS var based on `uname -s`
case "$(uname -s)" in
  Linux*)
    OS=linux
    ;;
  Darwin*)
    OS=macos
    ;;
  *)
    echo "Currently only Linux and MacOS binaries can be downloaded from Lamdera artifact server!"
    exit 1
    ;;
esac

ARCH="$(uname -m)"

LAMDERA_VERSION="1.1.0"

LAMDERA_URL="https://static.lamdera.com/bin/lamdera-$LAMDERA_VERSION-$OS-$ARCH"

curl "$LAMDERA_URL" -o node_modules/.bin/lamdera
chmod a+x node_modules/.bin/lamdera

cat <<EOF
======

  _        _    __  __ ____  _____ ____      _
 | |      / \  |  \/  |  _ \| ____|  _ \    / \\
 | |     / _ \ | |\/| | | | |  _| | |_) |  / _ \\
 | |___ / ___ \| |  | | |_| | |___|  _ <  / ___ \\
 |_____/_/   \_\_|  |_|____/|_____|_| \_\/_/   \_\\

lamdera $LAMDERA_VERSION installed to node_modules/.bin/lamdera!
You can use this from within npm scripts.
lamdera is used by elm-pages v3 as a replacement for elm compiler.

See https://dashboard.lamdera.app/docs for details about lamdera.

======
EOF
