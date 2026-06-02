# Exercise 7: Live App Bug Hunt — Buggy Admin Panel

| Detail     | Value          |
|------------|----------------|
| **Time**   | ~25 minutes    |
| **Points** | 20             |
| **Type**   | Run & Report   |

---

## Why This Exercise Exists

Some bugs can **only** be found by running the app and interacting with it. Reading code is not enough. This exercise tests your eye for UI/UX quality, your manual exploration discipline, and your ability to report bugs clearly enough that a dev can fix them.

---

## The App Under Test

**Open the hosted version (recommended — no setup):**
👉 **https://mazen-salah.github.io/qa-tester-assessment/app/buggy-admin/**

Or open `app/buggy-admin/index.html` from your forked clone in any modern browser. Either way it's a self-contained mock admin panel for a typical live-app backoffice — sending gifts, banning users, viewing wallet balances. **No server, no install, no build step.**

The app has **at least 10 intentional bugs** of varying severity. Some are obvious. Some require you to think like a user. Some only appear on specific input.

---

## Task

Find **at least 6 bugs** and report each one in `answers/visual_bugs_report.md` using this exact format:

```
## Bug #1: [Short title]
- **Where:** [Screen / button / form where it occurs]
- **Steps to reproduce:**
  1. Step 1
  2. Step 2
  3. ...
- **Expected behavior:** [What should happen]
- **Actual behavior:** [What actually happens]
- **Screenshot:** [Attach to answers/screenshots/ or paste a description]
- **Severity:** Critical / High / Medium / Low
- **Severity reasoning:** [One sentence — why this severity, not one higher or lower]
- **Suspected root cause:** [Frontend layout / Frontend logic / Backend / Data / API contract]
- **Proposed fix:** [Concrete suggestion]
```

---

## What to Look For

The bugs in this app fall into these categories — try to find at least one from each:

1. **Form validation** — fields accepting things they shouldn't
2. **Money / numbers** — wrong totals, off-by-one, currency formatting
3. **Authorization** — buttons or actions that should be guarded
4. **State / data** — stale UI after an action, missing empty states
5. **Layout / UX** — overflow, unclickable areas, confusing labels
6. **Accessibility** — keyboard nav, contrast, screen-reader labels
7. **Console errors** — errors in DevTools that the user can't see directly

---

## How to Test

- Try every button. Try them out of order.
- Try empty inputs. Try very long inputs. Try negative numbers, zero, decimals, unicode.
- Open the browser **DevTools Console** and watch for JS errors as you click around — at least one bug is only visible there.
- Resize the browser window to a phone-sized width
- Try keyboard-only navigation (Tab, Enter, Space)

---

## Submission

1. Create `answers/visual_bugs_report.md` with your bug reports
2. (Optional but strong signal) Include screenshots in `answers/screenshots/`
3. At the bottom of your report, write a 3-4 sentence **"How I tested"** section describing your overall approach
4. Commit everything to your repo

---

## Evaluation Criteria

| Criterion | Points | What We Look For |
|-----------|--------|------------------|
| Bugs found (min 6) | 7 | Real bugs, not false positives. Quality over quantity. |
| Severity discipline | 3 | Critical reserved for money/auth; not everything is High |
| Repro clarity | 4 | A dev could fix the bug from your steps alone |
| Root-cause hypothesis | 3 | You guess where it likely lives in the stack and why |
| Coverage breadth | 3 | At least 4 of the 7 categories above are represented |

---

## Important

- **AI cannot do this exercise.** It requires running the app and clicking.
- **Don't pad the list.** 4 well-written bugs beats 10 vague ones.
- The app has **at least one bug that is only visible in DevTools Console** — finding it is a strong signal.
- If you find something that looks like a security issue, mark it Critical and explain the impact.
