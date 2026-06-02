# Scenario 1: Greenfield Automation Strategy

## Week 1–2: First Thing I Build

First thing I do is read the routes file and map out what we're actually dealing with. I've worked on backend before so I can read Laravel code — I don't need a dev to explain every endpoint to me. I'll go through `routes/api.php` myself and group endpoints by risk: payments, auth, wallets, and the rest.

Then I build a small Postman collection — maybe 10–15 requests — just to confirm the environment works and I can actually hit the API. Login, one payment, one gift send. No fancy assertions yet, just making sure things respond.

I spend one of my dev pairing sessions on the payment flow specifically. Payments are always the messiest part — multiple providers, edge cases, weird states. I've been burned before by assuming I understood a payment flow and I was wrong.

**What I don't do in week 1–2:** I don't write PHPUnit tests yet. I don't touch CI. I don't try to cover 50 endpoints. I focus on understanding before I start building.

---

## Week 3–6: What Gets Tested First

I prioritize by "what breaks and costs real money or locks users out":

**First:** Payment endpoints — charge, refund, webhook handlers for Stripe and PayPal. Having backend experience helps here because I actually understand what the webhook listener is doing, not just that it exists.

**Second:** Auth — login, token refresh, password reset. A broken auth endpoint is silent death. Users just can't get in and you don't always see it immediately.

**Third:** Wallet — balance, credit, debit. Financial reads aren't as bad as writes but users notice wrong numbers immediately.

**Fourth:** Stream join/leave. Core product, fails loudly, easy to catch.

Everything else (profile edits, settings, content CRUD) — I leave for later or skip entirely in week 8. Those fail loudly and aren't catastrophic.

I'm writing 20–25 Postman requests per week, stored in git. Nothing fancy.

---

## Week 7–8: CI and Gating

I plug Newman into GitHub Actions. It runs the payment + auth collection on every PR that touches those files. Everything else runs nightly only.

My proposed gate: **PRs touching payments, auth, or wallet controllers must pass the collection. Everything else is advisory.**

I'm not proposing to block all releases — the team won't accept it and honestly at 8 weeks I haven't earned that trust yet. I gate the high-risk files and prove value first.

---

## Tooling: Postman + Newman

I pick Postman over PHPUnit feature tests for now, for one reason: speed. I came from backend so I *could* write PHPUnit tests, but setting up factories and database state for 400 endpoints takes time I don't have. With Postman I can write and run a test against staging in 10 minutes.

The tradeoff: Postman collections drift if nobody maintains them. I manage this by keeping the collection in git and making it part of the PR checklist for payment files.

I keep the existing PHPUnit concurrency tests for gift-sending. They're already there and they cover something specific — no reason to touch them.

---

## Coverage Target: 40% of High-Risk Endpoints

Not 40% of all 400. I mean 40% of the ~80–100 endpoints that actually matter (payments, auth, wallet, streams).

Higher than that in 8 weeks means shallow tests that only check status 200. Those catch nothing. I'd rather have 35 tests that each verify real behavior than 150 tests that just confirm the server responded.

---

## Payment Webhook Strategy

I never fire real charges in tests. My approach:

- **Local/PHPUnit:** Call the webhook controller directly with a crafted payload and a test signing secret. No network, no real money.
- **Postman against staging:** Use Stripe test-mode keys. Build the `Stripe-Signature` header in a pre-request script using the test secret. Staging uses Stripe test mode so nothing real happens.
- **stripe-cli** for local development: `stripe listen --forward-to localhost` — free tool, lets you trigger test events without touching production.

For PayPal same idea — sandbox credentials on staging, replicate the payload from their docs.

Secrets never hardcoded. Always `{{STRIPE_WEBHOOK_SECRET}}` in the Postman environment, real value in GitHub Secrets.

---

## The One Thing I Push Back On

In week 1 someone will ask: *"Can you just quickly cover everything so we have numbers to show?"*

I say no.

I've seen this before. You rush to write 200 tests, they all check status 200, everyone feels good, and then a real bug ships because the one test that mattered was written in 20 minutes and didn't actually verify anything. The number is a lie.

What I tell them: "Give me 8 weeks to write 40 tests that mean something. When one fails, you'll know exactly what broke. That's more valuable than 200 green lights that tell you nothing."

If they really want broad coverage fast, I offer to add a nightly smoke run — status-200 checks only, clearly labeled "smoke." Smoke passing means the API is up. Regression passing means the logic is correct. Two different things.
