# Scenario 2: Flaky Test Suite

## 1. Which Tests Do I Investigate First?

I export CI run history for the last 30 days and build a simple failure frequency table. In my experience flakiness is never evenly spread — usually 3 or 4 tests are causing 80% of the failures. I find those first.

After frequency, I look at what the test covers. A flaky Selenium test on the profile screen? Annoying. A flaky test on wallet balance? That's the one that will eventually let a real bug through — and it did.

I also flag tests that *recently became* flaky. If something was stable for 3 months and started failing 2 weeks ago, that usually means a real instability got introduced. That's not a flake, that's a bug with bad timing.

---

## 2. Quarantine Policy

Yes I quarantine — but with actual rules, not "we'll fix it later."

- A test gets quarantined if it fails 3+ times in the last 10 runs with no related code change.
- Quarantined tests move to a separate CI job. They still run, they just don't block merges. I still want to see if they catch something real.
- **Maximum 2 weeks in quarantine.** After that: fix it or delete it. No test stays in quarantine forever — that's just deleting it while pretending you haven't.
- The person who wrote the test owns the fix. If they're gone, whoever last touched the tested code owns it.
- I track it on a board with a due date. If the date passes I ping the dev and their lead.

---

## 3. Five Root Causes

**1. Shared database state between tests**
One test's data bleeds into another. The fix is `RefreshDatabase` or `DatabaseTransactions` traits in Laravel. I check the base test class first — if it's not there, that's probably the main issue.

**2. Time-dependent assertions**
Tests that say "this should complete in 2 seconds" fail when CI is slow. Mock the clock with `Carbon::setTestNow()`. Replace `sleep()` in Selenium with proper explicit waits.

**3. Selenium clicking before the DOM is ready**
Classic. Element is found, DOM re-renders, element is stale. Fix: explicit waits before every interaction on dynamic elements. I run the Selenium suite in slow-mo to find every click that's missing a wait.

**4. Real HTTP calls in tests**
If a feature test is hitting actual Stripe or PayPal endpoints, any network issue makes it fail. These should use `Http::fake()`. I grep for HTTP calls without fakes and add mocks.

**5. Async/queue race conditions**
Test asserts the result of a queued job before the job runs. Fix: use `Queue::fake()` and assert the job was dispatched, or switch to sync queue driver in test config.

---

## 4. The Wallet Test Post-Mortem

What actually happened: the test was flaky for 2 weeks, devs learned to ignore it, then a real bug came in and the test correctly failed — but nobody believed it anymore.

The root cause isn't the test. It's that a flaky test was left in the blocking suite for 2 weeks with no action taken.

If the quarantine policy existed, the day it started flaking intermittently it would have moved to non-blocking and a ticket would have been opened. The real bug would still have shown up in the quarantine job — but failing *consistently*, not intermittently, which is a completely different signal.

**Process change:** Any test that fails on 2 consecutive re-runs with no code change gets quarantined same day. Not next week. I also add a 15-minute weekly flake review to standup — we look at the quarantine board together. Makes it visible instead of buried.

---

## 5. Cutting the 22-Minute Run

The Selenium suite is ~11 minutes. That's the target.

**Fast wins:**
- Parallelize Selenium across 2 GitHub Actions runners using matrix strategy. Cuts it to ~6 minutes, zero code changes needed.
- Run PHPUnit and Newman in parallel instead of sequentially.

**Slightly more work:**
- Audit Selenium tests for overlap with PHPUnit/Newman tests. Any Selenium test that's just testing API logic (not actual UI behavior) gets deleted — the API layer already covers it.
- Selenium should only test things where the browser behavior itself is what you're testing, not the business logic underneath.

Target: under 12 minutes in 2 weeks, under 8 minutes in 6 weeks.

---

## 6. Stopping the Re-Run Habit

The re-run behavior makes sense when tests fail randomly 10% of the time. The only real fix is making flaky tests rare enough that a failure almost always means something real.

But practically:

- **Require a comment to re-run.** Add a GitHub Actions rule: manual re-run requires a short comment in the PR explaining why. Breaks the muscle memory, creates a paper trail.
- **Post flake rates publicly.** Weekly Slack message showing per-test failure rates. When the team can see "wallet test: 38% failure rate this week" it becomes a team conversation, not just a QA problem.
- **Show the wallet bug timeline in a team meeting.** Not to blame anyone — to show how the system failed and what changes prevent it. Data is more convincing than policy documents.
