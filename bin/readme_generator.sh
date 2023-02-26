#!/bin/bash
set -euo pipefail

# quick and dirty version

for gif in `ls | grep gif | sed 's/\.gif//'`; do
    echo "## $gif"
    echo "![](https://raw.githubusercontent.com/AaronVerDow/$1/master/animations/output/$gif.gif)"
done
