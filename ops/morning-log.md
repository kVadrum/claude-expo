# morning-log

Append-only record of autonomous overnight sessions run by Claude Code
against projects in this workspace. One line per session, newest at the
bottom. Read left-to-right: date, project, outcome.

Formats:
- Shipped: `YYYY-MM-DD ichnograph <short-sha> <one-line summary> duration=Nmin`
- Skipped: `YYYY-MM-DD ichnograph skipped — <brief reason>`
- Blocked: `YYYY-MM-DD ichnograph blocked — <what got in the way>`

kVadrum reads this in the morning and decides what (if anything) to
review, push, or revert.

---

