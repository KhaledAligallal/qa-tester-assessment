# Exercise 8: QA Strategy & Trade-off Decisions

| Detail     | Value          |
|------------|----------------|
| **Time**   | ~30 minutes    |
| **Points** | 20             |
| **Type**   | Written analysis |

---

## Why This Exercise Exists

Senior testers don't just execute test cases — they make decisions under constraints about **what to test, what to skip, and what to push back on**. There is **no single right answer** to these scenarios. We want to see how you think about trade-offs, risks, deadlines, and team dynamics.

Generic answers like "it depends on the requirements" score zero.
**Be specific. Be opinionated. Defend your choices.**

---

## Scenario 1: Greenfield Automation on a 400-Endpoint Laravel API (8 pts)

### Context

You've just been hired as the first QA on a Laravel 10 backend that has been in production for 3 years. It powers a live-streaming app with **multiple white-label flavors**. The current state:

- **Several hundred API endpoints** in `routes/api.php`, organized into modular folders by feature (auth, chat, payments, wallets, etc.)
- **About 20 existing PHPUnit tests** — mostly the auto-generated `ExampleTest.php`, plus a few real ones around concurrency in the gift-sending flow
- **Multiple payment provider integrations** with webhook callbacks (e.g., Stripe, PayPal)
- **Zero API documentation** outside the route file itself. No Swagger, no Postman collection.
- **CI runs on GitHub Actions** but currently only does `composer install` + `migrate --force` — no test execution
- Backend team is **3 devs**, releases to production **2-3 times per week**

### Constraints

- You get **8 weeks** before your first formal review
- Backend devs will give you **at most 4 hours/week** of pairing time
- You cannot block releases yet — the team won't accept it
- Budget for tools: ~$200/month

### Your Task

Write your plan in `answers/scenario_1_automation_strategy.md`:

1. **Week 1-2:** What's the FIRST thing you build? Why? What do you explicitly NOT do?
2. **Week 3-6:** Roll-out plan. Which endpoints/flows get automated first, and how do you prioritize across several hundred routes?
3. **Week 7-8:** What goes into CI? What's the gating policy you propose?
4. **Tooling:** Postman + Newman vs PHPUnit Feature tests vs both — pick and defend
5. **Coverage target:** What % of endpoints do you commit to at week 8? Justify the number
6. **Payment webhook strategy:** How do you test webhooks safely without firing real charges?
7. **What you push back on:** Name one thing the team will ask of you in week 1 that you will explicitly say no to, and why

---

## Scenario 2: Flaky Test Suite Eating Friday Afternoons (6 pts)

### Context

Three months in, the team likes your work. You now have **180 automated tests** running on every PR — mix of PHPUnit Feature tests, Postman/Newman API tests, and Selenium UI tests. But:

- Roughly **8-12% of CI runs fail on a flaky test**, not a real bug
- Devs are starting to mash "Re-run failed jobs" without investigating
- Last week the wallet-balance regression test passed CI but the bug shipped — because the same test had been flaky for 2 weeks and nobody believed it anymore
- Your CI runs take **22 minutes**, half of which is the Selenium suite

### Your Task

Write your answer in `answers/scenario_2_flaky_tests.md`:

1. **Triage:** Which tests do you investigate first? On what criteria?
2. **Quarantine policy:** Do you mute flakes? For how long? Who's accountable for fixing them?
3. **Root causes:** Name 5 specific reasons a Selenium or Laravel Feature test typically flakes, and what you'd do for each
4. **The wallet test that "cried wolf":** What's your post-mortem? What process change do you propose?
5. **CI time:** How do you cut the 22-minute run without dropping coverage? Be specific (sharding, parallel, selective re-run, removing UI tests…?)
6. **Cultural fix:** How do you change developer behavior so they stop mashing "Re-run"?

---

## Scenario 3: Release Deadline vs Mobile Regression Coverage (6 pts)

### Context

The Flutter app ships **multiple white-label flavors** from a single codebase. Marketing has committed to launching a new flavor "PartyChat" to a specific country **in 9 days** for a campaign tied to a holiday.

Engineering is on schedule. But your **regression test pass for all existing flavors takes 3 days** of manual work (you have zero Flutter widget/integration test automation). If you regress every flavor before the PartyChat release, you have **6 days of buffer** for any issues. If you regress only PartyChat + your top 5 highest-revenue flavors, you have **8 days of buffer** but increase the risk of a regression in the rest.

The CEO is asking you directly: "Can we ship in 9 days without dropping any regression?"

### Your Task

Write your answer in `answers/scenario_3_release_decision.md`:

1. **Your recommendation to the CEO** — what do you actually say in that meeting? (1-2 paragraph script)
2. **Risk-based prioritization:** How do you decide which flavors to regress vs which to skip?
3. **What's the smallest test set** that gives you 80% confidence across every flavor? Be specific about which test cases — auth, payment, send-gift, video stream, etc.
4. **Automation seeding:** Even with 9 days, what's the ONE flutter_test or integration_test you'd write first to make future regressions cheaper?
5. **Post-launch monitoring:** What do you watch in production for the first 72 hours after PartyChat ships, and what's the rollback trigger?
6. **If the CEO says "no, regress everything":** What do you ask for in exchange?

---

## Evaluation Criteria

| Criterion | Points | What We Look For |
|-----------|--------|------------------|
| Specificity | 6 | Concrete plans with names, numbers, weeks — not vague "we should..." |
| Trade-off awareness | 5 | Acknowledges downsides of chosen approach |
| Realism | 4 | Plan is achievable with the stated constraints |
| Push-back / opinion | 3 | You're willing to disagree (politely) with the PM/CEO and say why |
| Communication | 2 | Well-structured, easy to follow, would convince a tech lead |

---

## Important

- **There is no single right answer.** We're evaluating your reasoning, not a specific conclusion.
- **AI will give you a generic answer.** We can tell. Add your personal experience and opinions.
- **Be opinionated.** "It depends" without a specific recommendation is a weak answer.
- If you've faced a similar situation in a previous QA job, reference it — that's the strongest signal you can give us.
- The CEO scenario is real — we ship multiple flavors and have had this exact conversation. Your answer is checked against what actually worked.
