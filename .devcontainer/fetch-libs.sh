#!/usr/bin/env bash
set -e

LIBS_DIR="$(cd "$(dirname "$0")/.." && pwd)/Libs"
mkdir -p "$LIBS_DIR"

svn_export() {
    local url="$1"
    local dest="$LIBS_DIR/$2"
    echo "Fetching $2..."
    svn export --force "$url" "$dest"
}

svn_export "https://repos.curseforge.com/wow/libstub/trunk"                    "LibStub"
svn_export "https://repos.curseforge.com/wow/callbackhandler/trunk"            "CallbackHandler-1.0"
svn_export "https://repos.curseforge.com/wow/ace3/trunk/AceAddon-3.0"          "AceAddon-3.0"
svn_export "https://repos.curseforge.com/wow/ace3/trunk/AceDB-3.0"             "AceDB-3.0"
svn_export "https://repos.curseforge.com/wow/ace3/trunk/AceDBOptions-3.0"      "AceDBOptions-3.0"
svn_export "https://repos.curseforge.com/wow/ace3/trunk/AceGUI-3.0"            "AceGUI-3.0"
svn_export "https://repos.curseforge.com/wow/ace3/trunk/AceConfig-3.0"         "AceConfig-3.0"

echo "Done. Ace3 libraries installed to $LIBS_DIR"
