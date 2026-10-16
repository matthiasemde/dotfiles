# USAGE: txt2htmlPreview <file.txt>

# Wraps raw HTML elements in a file into a full HTML document and previews
# it in the default browser. Press Ctrl+C in the browser to stop watching.

set -euo pipefail

file="${1:?Usage: txt2htmlPreview <file.txt>}"
tmp=$(mktemp /tmp/preview-XXXXXX.html)
trap "rm -f $tmp" EXIT

cat > "$tmp" <<INNER_EOF
<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8"><title>$(basename "$file")</title>
<style>body{max-width:900px;margin:2rem auto;padding:0 1rem;font-family:system-ui}</style>
</head><body>
INNER_EOF
cat "$file" >> "$tmp"
echo "</body></html>" >> "$tmp"

xdg-open "$tmp" &

# Keep the script alive until Ctrl+C.
while kill -0 $$ 2>/dev/null; do sleep 1; done
