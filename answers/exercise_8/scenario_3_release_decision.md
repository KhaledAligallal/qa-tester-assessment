# Scenario 3: Release Deadline vs Regression Coverage

## 1. What I Say to the CEO

"We can ship in 9 days. Here's the honest version of what that means.

Full regression on every flavor takes 3 days. If we do that, we have 6 days of buffer. If we regress only PartyChat plus the top 5 revenue flavors, we save 2 days and have 8 days of buffer — but we accept the risk that something breaks in a smaller flavor and we don't catch it before launch.

My recommendation is the second option. Most flavors share the same core code, so a regression that hits a small flavor will almost always show up on one of the top 5 where we're looking. What I need from you right now is: which 5 flavors are highest priority, and what's our rollback trigger if something goes wrong after launch. Those two things are what I need to feel okay about shipping."

---

## 2. Which Flavors to Regress vs Skip

I pick the top 5 based on:

- **Highest active users** — most exposure if something breaks
- **Highest revenue** — payment flows, subscriptions, in-app purchases
- **Most recently changed config** — if a flavor had changes in the last 2 sprints it gets tested regardless of revenue rank
- **Most different from the others** — flavors with custom payment providers or regional-specific logic are the ones most likely to have unique regressions

Flavors I skip: low-MAU, low-revenue ones that are basically identical to a top-5 flavor with a different color scheme. If they share the same backend config, testing the main one covers them.

---

## 3. Smallest Test Set for 80% Confidence

For each flavor I test (PartyChat + top 5), I run this set — roughly 4–5 hours per flavor, not a full day:

| Test | Why |
|---|---|
| Register + email verification | Auth is the entry gate |
| Login (valid / invalid / locked) | Silent failure if broken |
| Token refresh | Breaks the app quietly after a session expires |
| In-app purchase + receipt validation | Money. Different provider per flavor sometimes. |
| Gift send (happy path + insufficient balance) | Core feature, previously known fragile |
| Wallet balance + credit/debit | Users notice wrong numbers immediately |
| Video stream join + leave | Core product, visible failure |
| Logout + token invalidation | Security regression, easy to miss |
| Flavor-specific feature flags | Make sure the flavor's unique features are on/off correctly |

What I skip: profile editing, settings, content browsing, social features (follow/unfollow). These fail loudly and aren't revenue-critical.

6 flavors × ~25 test cases = manageable in 3 days with 2 testers, leaving 6 days buffer.

---

## 4. The One Flutter Test to Write

Login flow. That's it.

```dart
testWidgets('Login navigates to home screen', (tester) async {
  app.main();
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(Key('email_field')), testEmail);
  await tester.enterText(find.byKey(Key('password_field')), testPassword);
  await tester.tap(find.byKey(Key('login_button')));
  await tester.pumpAndSettle(Duration(seconds: 3));
  expect(find.byKey(Key('home_screen')), findsOneWidget);
});
```

Why this one: every other test needs auth to work first. Once this exists as a helper, the next 20 tests are faster to write. I also make it read the flavor config from an env variable so PartyChat and every future flavor runs the same test.

---

## 5. Post-Launch Monitoring — First 72 Hours

Things I watch:

- **Crash rate** — baseline from existing flavors is around 0.3%. If PartyChat hits above 1% in the first hour, that's a call to the tech lead.
- **Payment failure rate** — above 8% failed purchase events in the first 2 hours means something is broken in the payment flow for this region.
- **Auth errors (4xx on login/token endpoints)** — above 5% error rate means registration or login is broken. I set an alert on this before launch.
- **Stream join failures** — above 5% of join attempts failing means a region or infrastructure issue.
- **Gift send errors** — canary for wallet and payment logic.

If any P0 metric hits 3× baseline for more than 15 minutes, I call the tech lead and we decide on rollback together. Not automatic rollback — but I'm not waiting 2 hours to raise the flag either.

Ideally I push for a staged rollout — 1% of users first, then 10%, then 100% — over the first couple hours. Limits blast radius while we confirm things are stable.

---

## 6. If the CEO Says "Regress Everything"

I say: "Okay, I need one of these:"

1. **One extra tester for 3 days.** Contract is fine. Two testers can finish full regression and still have 6 days buffer. Probably $800–1200.
2. **2-day extension.** Ship day 11. Full regression done, same buffer, campaign still hits the holiday if it's more than 2 weeks out.
3. **We agree "full regression" means my 80% test set applied to all flavors, not just top 5.** I can do all flavors in 9 days with that scope.

I present these as real options. What I won't do is say yes to "regress everything" and then quietly scope it down without telling anyone. That's how you end up in a post-mortem.
