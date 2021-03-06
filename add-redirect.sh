#!/bin/bash -e

# Credit for this code goes to https://github.com/line/go-import-redirects
# It is modified here for go.nanomsg.org.
# The upstream was missing any clear license.

case "$1" in
-v*)
	VERS="${1#-}"
	shift
	;;
esac

if [[ $# -ne 2 ]] && [[ $# -ne 3 ]]; then
  echo "Usage: $0 [-v{vers}] <src> <dest> [<suffix>]"
  echo "Examples:"
  echo
  echo "1) $0 foo bar"
  echo
  echo "   'import \"go.nanomsg.org/foo/[v{vers}/]\"' is redirected to 'https://github.com/nanomsg/bar.git'"
  echo
  echo "2) $0 foo bar qux"
  echo
  echo "   'import \"go.nanomsg.org/foo/[v{vers}/]qux\"' is redirected to the package 'qux' in 'https://github.com/nanomsg/bar.git'"
  echo
  exit 1
fi

SRC="$1"
DST="$2"
SUFFIX="$3"

if [[ ! "$SRC" =~ (^([-_0-9a-zA-Z]+/)*[-_0-9a-zA-Z]+$) ]]; then
  echo "Invalid source: $SRC"
  exit 1
fi

if [[ ! "$DST" =~ (^[-_0-9a-zA-Z]+$) ]]; then
  echo "Invalid destination: $DST"
  exit 1
fi

if [[ -n "$SUFFIX" ]] && [[ ! "$SUFFIX" =~ (^([-_0-9a-zA-Z]+/)*[-_0-9a-zA-Z]+$) ]]; then
  echo "Invalid suffix: $SUFFIX"
  exit 1
fi

cd "$(dirname "$0")"
IMPORT_ROOT="go.nanomsg.org/$SRC"
GODOC_URL="https://godoc.org/$IMPORT_ROOT"

SRC_DIR="$SRC"
if [[ -n "$VERS" ]]; then
	SRC_DIR="${SRC_DIR}/${VERS}"
fi
if [[ -n "$SUFFIX" ]]; then
  GODOC_URL="$GODOC_URL/$SUFFIX"
  SRC_DIR="$SRC_DIR/$SUFFIX"
fi

mkdir "$SRC_DIR"

echo "<!DOCTYPE html>
<html>
<head>
<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/>
<meta name=\"go-import\" content=\"$IMPORT_ROOT git https://github.com/nanomsg/$DST\">
<meta name=\"go-source\" content=\"$IMPORT_ROOT https://github.com/nanomsg/$DST/ https://github.com/nanomsg/$DST/tree/master{/dir} https://github.com/nanomsg/$DST/blob/master{/dir}/{file}#L{line}\">
<meta http-equiv=\"refresh\" content=\"0; url=$GODOC_URL\">
</head>
<body>
Redirecting to docs at <a href=\"$GODOC_URL\">$GODOC_URL</a>...
</body>
</html>
" > "$SRC_DIR/index.html"
