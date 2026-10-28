# homelab-backup

Home page and privacy policy of **Homelab backup**, a private Google API client used by one person, its owner. It
backs up the owner's own Gmail (read only) and keeps the copies encrypted, on the owner's own computers and in the
owner's own Google Drive (only the files it creates).

Why this repository exists: Google asks for a home page URL and a privacy policy URL before an External OAuth app
can move from "Testing" to "In production", even when only one person uses it. In "Testing" every authorisation
ends after 7 days, which would stop an unattended backup every week.

- Home page: https://konzag.github.io/homelab-backup/
- Privacy policy: https://konzag.github.io/homelab-backup/privacy.html

The pages hold no names, email addresses or other personal data, load nothing from anywhere and set no cookies.
Run both checks before every push (Git Bash or Linux):

    bash tests/check-site.sh    # the site
    bash tests/selftest.sh      # the check itself: each planted fault must fail

GitHub Pages serves the `main` branch as it is (`.nojekyll`: no Jekyll build).
