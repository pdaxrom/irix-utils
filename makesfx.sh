#!/bin/sh

if [ $# -lt 2 ]; then
    echo "Usage: $0 archive.tar.gz output.sh"
    exit 1
fi

ARCHIVE="$1"
OUTPUT="$2"

if [ ! -f "$ARCHIVE" ]; then
    echo "Archive not found: $ARCHIVE"
    exit 1
fi

TMP="/tmp/sfxhdr.$$"

cat > "$TMP" <<'EOF'
#!/bin/sh

PATH=/bin:/usr/bin:/usr/bsd:/usr/freeware/bin:/usr/local/bin:$PATH
export PATH

DEST="/"

echo "Self-extracting archive"
echo "Destination: $DEST"

if [ "`id -u 2>/dev/null`" != "0" ]; then
    echo "Warning: extracting to / usually requires root."
fi

SKIP=__SKIP__

cd "$DEST" || {
    echo "Cannot cd to $DEST"
    exit 1
}

tail +$SKIP "$0" | gunzip -c | tar xvf -

STATUS=$?

if [ $STATUS -ne 0 ]; then
    echo "Extraction failed."
    exit $STATUS
fi

echo "Done."
exit 0
EOF

LINES=`wc -l < "$TMP" | sed 's/ //g'`
SKIP=`expr "$LINES" + 1`

sed "s/__SKIP__/$SKIP/" "$TMP" > "$OUTPUT"
cat "$ARCHIVE" >> "$OUTPUT"
chmod +x "$OUTPUT"

rm -f "$TMP"

echo "Created: $OUTPUT"
echo "Default extraction path: /"
