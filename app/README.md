# App Under Test

This directory contains the mock app(s) used by **Exercise 7** (Live Bug Hunt) and **Exercise 6** (Video Walkthrough).

## buggy-admin

A self-contained mock admin panel for a typical live-app backoffice (send gifts, manage users, view wallets).

**Live URL:** https://mazen-salah.github.io/qa-tester-assessment/app/buggy-admin/

**Or run locally:** open `buggy-admin/index.html` directly in any modern browser.

- No server, no install, no build step.
- It uses only vanilla HTML / CSS / JS.
- All "data" is local to the page — your changes don't persist anywhere.

The app contains **at least 10 intentional bugs** of varying severity across the categories listed in `exercises/exercise_7_live_app_bug_hunt.md`. Your job is to find them, not to fix them.

> **Note:** This is a deliberately-buggy mock built to give you a realistic, time-bounded surface to test. It is not the codebase you'd work on if hired — that's a much larger system with hundreds of endpoints and a Flutter mobile app. This is a slice designed for the assessment.

## Hints (without spoilers)

- Open the **browser DevTools Console** as soon as you load the page — and watch it as you interact.
- Try the math on the **Send Gift** form with a calculator.
- Try the **wallet balance shown in the header** vs the wallet balance shown on the Wallet tab — are they the same? Should they be?
- Check **localStorage** in DevTools → Application tab.
- Resize the browser to mobile width.
