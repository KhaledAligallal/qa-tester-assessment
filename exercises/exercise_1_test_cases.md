# Exercise 1: Test Case Design — Concurrency-Sensitive Payment API

| Detail     | Value          |
|------------|----------------|
| **Time**   | ~30 minutes    |
| **Points** | 20             |
| **Type**   | Written test case design |

---

## Why This Exercise Exists

Writing test cases is the single most-used QA skill on this team. Our backend has an endpoint that **moves real money between user wallets** under high concurrency. A missed edge case here doesn't fail a build — it duplicates a user's coins, drops a paid gift, or worse.

We want to see how you think about coverage **before** any automation exists. Generic test cases like "verify the API returns 200" score zero. **Be specific. Think like an attacker, not just a user.**

---

## The Feature

Users in a live-stream room can send a virtual **Gift** (paid for with in-app coins) to the room. When sending, the user also picks `winners_count` — the backend then picks a **random subset of viewers** currently in that room and credits each of them a small bonus payout in coins (a common live-app feature pattern: TikTok Live gifts, Bigo Live raffles, Twitch bits with viewer rewards).

**Why testing this is interesting:** the endpoint moves coins between wallets under concurrency, broadcasts a real-time event to everyone in the room, integrates with payment-funded balances, and must be idempotent against retries from flaky mobile networks.

## API Spec — `POST /api/gifts/send`

The endpoint is **authenticated via Laravel Sanctum bearer token** and rate-limited at **30 requests/minute per user**.

### Request

```http
POST /api/gifts/send HTTP/1.1
Host: api.example.com
Authorization: Bearer {sanctum_token}
Content-Type: application/json

{
  "room_id": 12345,
  "gift_id": 7,
  "quantity": 10,
  "winners_count": 5,
  "idempotency_key": "uuid-v4-here"
}
```

### Validation rules

- `room_id` — required, integer, must reference an existing room the user is currently joined to
- `gift_id` — required, integer, must reference a gift the sender owns or can purchase
- `quantity` — required, integer, between 1 and 100
- `winners_count` — required, integer, between 1 and 50, must be ≤ current room audience size
- `idempotency_key` — required, UUID v4, must be unique per user for 24h
- Sender's wallet must have `quantity × gift.coin_price` coins or more

### Success response (200)

```json
{
  "transaction_id": 98765,
  "coins_charged": 5000,
  "winners": [
    { "user_id": 222, "coins_awarded": 250 },
    { "user_id": 333, "coins_awarded": 250 }
  ],
  "remaining_balance": 12000
}
```

### Known constraints

- The endpoint internally uses a database transaction with row-level locking on `wallets.user_id`
- A WebSocket event `gift.sent` is broadcast to the room channel on success
- Multiple payment providers can top-up the wallet (e.g., Stripe, PayPal) — top-ups land asynchronously via webhook

---

## Your Task

Write your test cases in `answers/exercise_1_test_cases.md` (or fill in this file directly). Group them under the headings below. Aim for **20-30 test cases total** — quality over count.

For each test case use this format:

```
### TC-XX: [Short title]
- **Category:** Happy path / Validation / Auth / Concurrency / Security / Business logic / Performance
- **Priority:** P0 / P1 / P2 / P3
- **Preconditions:** [What state must exist before this runs]
- **Steps:** [Numbered, specific]
- **Expected Result:** [What we assert — status code, response body fields, DB state, side effects like broadcast events]
- **Why it matters:** [One sentence — what bug would this catch in production?]
```

### Required sections (write at least the indicated count)

1. **Happy path** (2-3 cases)
2. **Field validation** (4-6 cases) — boundary values, types, missing fields
3. **Authentication & authorization** (3-4 cases) — invalid token, expired, wrong user, room not joined
4. **Concurrency / race conditions** (3-4 cases) — this is where the bugs hide
5. **Idempotency** (2 cases) — same `idempotency_key` replayed
6. **Business logic & money** (3-4 cases) — insufficient balance, room empty, winner == sender
7. **Side effects** (2 cases) — WebSocket / broadcast event delivery, DB transaction rollback
8. **Negative / security** (2 cases) — SQL/JSON injection in IDs, very large `quantity`

---

## Evaluation Criteria

| Criterion | Points | What We Look For |
|-----------|--------|------------------|
| Coverage breadth | 5 | All 8 categories addressed; not just happy path |
| Concurrency thinking | 5 | Real race-condition cases (parallel sends, wallet lock contention, audience changing mid-call) |
| Specificity | 4 | Exact status codes, exact DB assertions, named fields — not "verify response" |
| Priority discipline | 3 | P0/P1 reserved for money-loss & auth bypass; not everything is P0 |
| Bug-catching framing | 3 | Each test ties back to "what bug would this catch" |

---

## Important

- **AI will hand you a generic CRUD test list.** We can tell. Add the cases that come from having actually shipped a payment/wallet feature.
- A test case that says "verify response status is 200 OK" with no other detail is worth nothing.
- If you spot a gap or ambiguity in the spec above, **call it out** — that's a strong signal. Senior testers don't accept specs at face value.
- Concurrency cases should describe exactly **what runs in parallel** and **what shared state could be corrupted**.
