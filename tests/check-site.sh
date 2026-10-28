#!/usr/bin/env bash
# tests/check-site.sh [DIR] - checks the site in DIR (default: the repository root). Fails on: a missing page, head
# element or .nojekyll; a missing link between the pages; a statement missing from the privacy policy; an email
# address or a phone number; a script, image, style or frame loaded from anywhere; a plain http link; a non-ASCII byte.
# All checks run and every failure is listed. tests/selftest.sh proves each check catches its fault.
set -uo pipefail

dir=${1:-"$(cd "$(dirname "$0")/.." && pwd)"}
pages=(index.html privacy.html)
fails=0
fail() { echo "FAIL $*"; fails=$((fails + 1)); }
has() { [ -f "$dir/$1" ] && grep -qiF -e "$2" "$dir/$1" || fail "$1 lacks: $2"; }

for p in "${pages[@]}"; do
    [ -f "$dir/$p" ] || { fail "missing $p"; continue; }
    head -c 15 "$dir/$p" | grep -qix '<!doctype html>' || fail "$p does not start with <!doctype html>"
    for s in '<html lang="en">' '<meta charset="utf-8">' '<meta name="viewport"' '<title>' '</html>'; do has "$p" "$s"; done
done
[ -f "$dir/.nojekyll" ] || fail 'missing .nojekyll (GitHub Pages would run Jekyll on the site)'

# the home page names the app and links to the policy; the policy links back
has index.html '<h1>Homelab backup</h1>'
has index.html 'href="privacy.html"'
has privacy.html 'Homelab backup'
has privacy.html 'href="./"'

# what Google asks of the policy, and what the owner was promised
for s in 'gmail.readonly' 'drive.file' 'Limited Use' 'https://developers.google.com/terms/api-services-user-data-policy' \
         'not shared' 'no cookies' 'https://myaccount.google.com/connections' 'Last updated:'; do
    has privacy.html "$s"
done

# no personal data, plain ASCII
for f in "${pages[@]}" README.md; do
    [ -f "$dir/$f" ] || continue
    grep -nE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' "$dir/$f" && fail "$f holds an email address"
    grep -nE '\+[0-9]{2,3}[ .-]?[0-9]|[0-9]{10,}' "$dir/$f" && fail "$f holds a phone number"
    LC_ALL=C grep -nP '[^\x00-\x7F]' "$dir/$f" && fail "$f holds a non-ASCII byte"
done

# nothing is loaded from anywhere; every link inside the site points at a page that exists
for p in "${pages[@]}"; do
    [ -f "$dir/$p" ] || continue
    grep -niE '<script|<iframe|<img|<link|<object|<embed|@import|url\(|src=' "$dir/$p" && fail "$p loads something"
    grep -noE 'href="http:[^"]*"' "$dir/$p" && fail "$p has a plain http link"
    while IFS= read -r h; do
        t=$h
        [ "$t" = './' ] && t=index.html
        [ -f "$dir/$t" ] || fail "$p links to a missing page: $h"
    done < <(grep -oE 'href="[^"#]*"' "$dir/$p" | cut -d'"' -f2 | grep -vE '^[a-z]+:')
done

if [ "$fails" -eq 0 ]; then echo 'check-site: ok'; else echo "check-site: $fails failure(s)"; exit 1; fi
