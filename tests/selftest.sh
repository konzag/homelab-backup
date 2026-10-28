#!/usr/bin/env bash
# tests/selftest.sh - proves tests/check-site.sh catches every fault it looks for: a clean copy of the site passes,
# and each planted fault fails with its own message. Works only in a temporary copy.
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
check="$root/tests/check-site.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
n=0
bad=0

fresh() {
    rm -rf "$tmp/s"
    mkdir -p "$tmp/s"
    cp "$root/index.html" "$root/privacy.html" "$root/README.md" "$root/.nojekyll" "$tmp/s/"
}
expect_fail() { # $1 the planted fault, $2 the message it must produce
    local out
    n=$((n + 1))
    if out=$(bash "$check" "$tmp/s" 2>&1); then
        echo "MISSED $1"; bad=$((bad + 1))
    elif grep -qF -e "$2" <<< "$out"; then
        echo "ok     $1"
    else
        echo "WRONG  $1:"; echo "$out"; bad=$((bad + 1))
    fi
}

fresh
if bash "$check" "$tmp/s" > /dev/null; then echo 'ok     a clean copy passes'; else echo 'FAIL   a clean copy fails'; bad=$((bad + 1)); fi

fresh; sed -i 's|</main>|<p>someone@example.com</p></main>|' "$tmp/s/index.html"
expect_fail 'an email address' 'index.html holds an email address'
fresh; sed -i 's|</main>|<p>+30 2101234567</p></main>|' "$tmp/s/privacy.html"
expect_fail 'a phone number' 'privacy.html holds a phone number'
fresh; sed -i 's|</head>|<script src="https://example.com/a.js"></script></head>|' "$tmp/s/index.html"
expect_fail 'a script' 'index.html loads something'
fresh; sed -i 's|</head>|<link rel="stylesheet" href="https://example.com/a.css"></head>|' "$tmp/s/privacy.html"
expect_fail 'a style from another site' 'privacy.html loads something'
fresh; sed -i 's|href="privacy.html"|href="policy.html"|' "$tmp/s/index.html"
expect_fail 'the link to the policy' 'index.html lacks: href="privacy.html"'
fresh; sed -i 's|href="./"|href="home.html"|' "$tmp/s/privacy.html"
expect_fail 'a link to a missing page' 'privacy.html links to a missing page: home.html'
fresh; sed -i 's|Limited Use|limited|' "$tmp/s/privacy.html"
expect_fail 'the Limited Use statement' 'privacy.html lacks: Limited Use'
fresh; sed -i 's|gmail.readonly|gmail|' "$tmp/s/privacy.html"
expect_fail 'the Gmail scope' 'privacy.html lacks: gmail.readonly'
fresh; sed -i 's|https://myaccount.google.com/connections|http://myaccount.google.com/connections|' "$tmp/s/privacy.html"
expect_fail 'a plain http link' 'privacy.html has a plain http link'
fresh; sed -i '1s|.*|<html>|' "$tmp/s/index.html"
expect_fail 'the doctype' 'index.html does not start with <!doctype html>'
fresh; rm "$tmp/s/.nojekyll"
expect_fail 'the .nojekyll file' 'missing .nojekyll'
fresh; printf 'caf\xc3\xa9\n' >> "$tmp/s/README.md"
expect_fail 'a non-ASCII byte' 'README.md holds a non-ASCII byte'
fresh; rm "$tmp/s/privacy.html"
expect_fail 'a missing page' 'missing privacy.html'

echo "selftest: $n planted faults, $bad not caught"
[ "$bad" -eq 0 ]
