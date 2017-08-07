#!/usr/bin/env bash

set -e

browser=$(tempfile)
js=$(tempfile)
trap "rm -f '$browser' '$js'" EXIT

base='https://chromium.googlesource.com'
curl -s "$base/chromium/src/+/master/third_party/WebKit/Source/core/inspector/browser_protocol.json?format=TEXT" | base64 -d >"$browser"
curl -s "$base/v8/v8/+/master/src/inspector/js_protocol.json?format=TEXT" | base64 -d >"$js"
node -p '
    const protocols = process.argv.slice(1).map((path) => JSON.parse(fs.readFileSync(path)));
    protocols[0].domains.push(...protocols[1].domains);
    JSON.stringify(protocols[0], null, 4);
' "$browser" "$js" >lib/protocol.json

git diff lib/protocol.json
