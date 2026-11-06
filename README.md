# homelab-backup

Home page and privacy policy of two private Google API clients of one family:

- **Homelab backup**, used by one person, its owner: it backs up the owner's own Gmail (read only) and keeps the copies
  encrypted, on the owner's own computers and in the owner's own Google Drive (only the files it creates).
- **Family calendar** (since 29 October 2026), used by the owner and the owner's children: it writes each person's
  reminders into a calendar it creates in that person's Google Calendar (scope calendar.app.created only).

Why this repository exists: Google asks for a home page URL and a privacy policy URL before an External OAuth app
can move from "Testing" to "In production", even when only one family uses it. In "Testing" every authorisation
ends after 7 days, which would stop the unattended backup and the calendar sync every week. Both Google Cloud
projects point at the same two pages.

- Home page: https://konzag.github.io/homelab-backup/
- Privacy policy: https://konzag.github.io/homelab-backup/privacy.html

Since 7 November 2026 the site also holds the two pages of the **Guesthouse tools** of the family business:
**Guesthouse bookings** (the booking app writes the stays into a calendar it creates, scope calendar.app.created) and
**Mail assistant** (being built: labels, archive and drafts in the business Gmail with gmail.modify, never sending;
invoice copies with drive.file; reminders with calendar.app.created). Their Google Cloud projects point at:

- Home page: https://konzag.github.io/homelab-backup/guesthouse.html
- Privacy policy: https://konzag.github.io/homelab-backup/guesthouse-privacy.html

The pages hold no names, email addresses or other personal data, load nothing from anywhere and set no cookies.
Run both checks before every push (Git Bash or Linux):

    bash tests/check-site.sh    # the site
    bash tests/selftest.sh      # the check itself: each planted fault must fail

GitHub Pages serves the `main` branch as it is (`.nojekyll`: no Jekyll build).
