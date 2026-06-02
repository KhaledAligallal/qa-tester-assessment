# Exercise 1 - Test Case Design

## 1. Happy Path

### TC-01: Send gift successfully with valid balance and valid room audience

* **Category:** Happy path

* **Priority:** P0

* **Preconditions:**

  * User authenticated with valid Sanctum token
  * User joined room_id 12345
  * Wallet balance = 10000 coins
  * Gift exists with coin_price = 500
  * Room audience size = 20 users

* **Steps:**

  1. Send POST `/api/gifts/send` with valid payload
  2. Set `quantity = 10` and `winners_count = 5`
  3. Use a valid UUID v4 `idempotency_key`

* **Expected Result:**

  * Response status = `200 OK`
  * `transaction_id` returned
  * `coins_charged = 5000`
  * `remaining_balance = 5000`
  * Winners list returned with 5 users
  * Winners credited in DB
  * `gift.sent` WebSocket event broadcasted to room

* **Why it matters:**
  Ensures the full wallet deduction and reward distribution flow works correctly.

---

### TC-02: Send gift when wallet balance equals exact required amount

* **Category:** Happy path

* **Priority:** P0

* **Preconditions:**

  * User authenticated
  * User joined room
  * Wallet balance exactly equals `quantity × gift.coin_price`

* **Steps:**

  1. Send request with exact payable amount

* **Expected Result:**

  * Request succeeds with `200 OK`
  * Wallet balance becomes `0`
  * Coins deducted accurately

* **Why it matters:**
  Prevents edge-case bugs where exact balances are incorrectly rejected.

---

### TC-03: Send gift with winners_count equal to room audience size

* **Category:** Happy path

* **Priority:** P1

* **Preconditions:**

  * Room contains exactly 5 viewers
  * `winners_count = 5`

* **Steps:**

  1. Send request with valid data

* **Expected Result:**

  * Request succeeds
  * All room viewers selected as winners
  * No duplicate winner entries

* **Why it matters:**
  Validates boundary logic for room audience selection.

---

## 2. Field Validation

### TC-04: Send request without room_id

* **Category:** Validation

* **Priority:** P0

* **Preconditions:** Valid authentication token

* **Steps:**

  1. Send request without `room_id`

* **Expected Result:**

  * Response status = `422 Unprocessable Entity`
  * Validation error for `room_id`

* **Why it matters:**
  Prevents incomplete payment requests.

---

### TC-05: Send request with quantity = 0

* **Category:** Validation

* **Priority:** P0

* **Preconditions:** Valid authentication token

* **Steps:**

  1. Send request with `quantity = 0`

* **Expected Result:**

  * Response status = `422`
  * Validation message for invalid quantity range

* **Why it matters:**
  Prevents invalid wallet calculations.

---

### TC-06: Send request with quantity > 100

* **Category:** Validation

* **Priority:** P1

* **Preconditions:** Valid authentication token

* **Steps:**

  1. Send request with `quantity = 101`

* **Expected Result:**

  * Response status = `422`
  * Validation error returned

* **Why it matters:**
  Prevents abuse or unexpected wallet charges.

---

### TC-07: Send request with invalid UUID format for idempotency_key

* **Category:** Validation

* **Priority:** P0

* **Preconditions:** Valid authentication token

* **Steps:**

  1. Send request with invalid `idempotency_key = "12345"`

* **Expected Result:**

  * Response status = `422`
  * Validation error for UUID format

* **Why it matters:**
  Prevents retry protection failure.

---

### TC-08: Send request with winners_count greater than room audience size

* **Category:** Validation

* **Priority:** P0

* **Preconditions:**

  * Room audience size = 3

* **Steps:**

  1. Send request with `winners_count = 5`

* **Expected Result:**

  * Response status = `422`
  * Proper validation error returned

* **Why it matters:**
  Prevents invalid reward distribution.

---

### TC-09: Send request with string value instead of integer

* **Category:** Validation

* **Priority:** P1

* **Preconditions:** Valid authentication token

* **Steps:**

  1. Send request with `room_id = "abc"`

* **Expected Result:**

  * Response status = `422`
  * Type validation error returned

* **Why it matters:**
  Prevents malformed payload processing.
## 3. Authentication & Authorization

### TC-10: Send request without bearer token

* **Category:** Auth

* **Priority:** P0

* **Preconditions:** None

* **Steps:**

  1. Send POST `/api/gifts/send` without Authorization header

* **Expected Result:**

  * Response status = `401 Unauthorized`
  * No wallet deduction occurs
  * No transaction created

* **Why it matters:**
  Prevents unauthorized users from spending coins.

---

### TC-11: Send request with invalid or expired Sanctum token

* **Category:** Auth

* **Priority:** P0

* **Preconditions:** Invalid/expired token

* **Steps:**

  1. Send request with expired bearer token

* **Expected Result:**

  * Response status = `401 Unauthorized`
  * Proper auth error message returned

* **Why it matters:**
  Prevents session hijacking or stale authentication usage.

---

### TC-12: User attempts to send gift to a room they have not joined

* **Category:** Authorization

* **Priority:** P0

* **Preconditions:**

  * User authenticated
  * User is not joined to target room

* **Steps:**

  1. Send request with valid room_id not joined by user

* **Expected Result:**

  * Response status = `403 Forbidden` or validation error
  * No wallet deduction
  * No transaction created

* **Why it matters:**
  Prevents room access bypass.

---

### TC-13: User attempts to send inaccessible or unauthorized gift

* **Category:** Authorization

* **Priority:** P1

* **Preconditions:**

  * Gift exists but sender does not own/cannot purchase it

* **Steps:**

  1. Send request using unauthorized `gift_id`

* **Expected Result:**

  * Request rejected
  * Response status = `403` or `422`
  * No wallet deduction

* **Why it matters:**
  Prevents gift ownership bypass.

---

## 4. Concurrency / Race Conditions

### TC-14: Same user sends two parallel gift requests with sufficient balance for only one

* **Category:** Concurrency

* **Priority:** P0

* **Preconditions:**

  * Wallet balance = 5000 coins
  * Each request requires 5000 coins

* **Steps:**

  1. Trigger two `/api/gifts/send` requests simultaneously using different idempotency keys

* **Expected Result:**

  * Only one request succeeds with `200 OK`
  * Second request fails due to insufficient balance
  * Wallet never becomes negative

* **Why it matters:**
  Validates row-level wallet locking and prevents double-spending.

---

### TC-15: Same request retried concurrently from unstable network

* **Category:** Concurrency

* **Priority:** P0

* **Preconditions:**

  * Valid request body
  * Same `idempotency_key`

* **Steps:**

  1. Send same request simultaneously 2–3 times

* **Expected Result:**

  * Only one transaction created
  * Coins deducted once only
  * Duplicate requests return same result or idempotent response

* **Why it matters:**
  Prevents duplicate charging from flaky mobile retries.

---

### TC-16: Audience changes during request execution

* **Category:** Concurrency

* **Priority:** P1

* **Preconditions:**

  * Room audience size = 5

* **Steps:**

  1. Send request with `winners_count = 5`
  2. Simultaneously remove users from room

* **Expected Result:**

  * Request handled gracefully
  * No server crash
  * Winners selected consistently based on transaction timing

* **Why it matters:**
  Detects race conditions in live-room state changes.

---

### TC-17: Wallet top-up webhook arrives during gift send

* **Category:** Concurrency

* **Priority:** P1

* **Preconditions:**

  * User wallet near insufficient balance

* **Steps:**

  1. Trigger gift send request
  2. Simultaneously simulate wallet top-up webhook

* **Expected Result:**

  * Final wallet balance remains consistent
  * No duplicate or missing coins

* **Why it matters:**
  Prevents balance corruption from async payment providers.

---

## 5. Idempotency

### TC-18: Replay request with same idempotency_key within 24 hours

* **Category:** Idempotency

* **Priority:** P0

* **Preconditions:**

  * Successful previous request exists

* **Steps:**

  1. Send successful request
  2. Replay exact same request with same key

* **Expected Result:**

  * No new transaction created
  * Wallet not charged again
  * Previously generated transaction returned

* **Why it matters:**
  Prevents duplicate payments during retries.

---

### TC-19: Reuse same idempotency_key with modified payload

* **Category:** Idempotency

* **Priority:** P0

* **Preconditions:** Existing idempotency key already used

* **Steps:**

  1. Send request with same key but different quantity/gift

* **Expected Result:**

  * Request rejected (`409 Conflict` or validation error)

* **Why it matters:**
  Prevents malicious replay attacks.

---

## 6. Business Logic & Money

### TC-20: Send gift with insufficient wallet balance

* **Category:** Business logic

* **Priority:** P0

* **Preconditions:**

  * Wallet balance lower than required amount

* **Steps:**

  1. Send valid request

* **Expected Result:**

  * Response rejected (`400` or `422`)
  * No wallet deduction
  * No transaction created

* **Why it matters:**
  Prevents overspending.

---

### TC-21: winners_count exceeds audience after validation

* **Category:** Business logic

* **Priority:** P1

* **Preconditions:**

  * Audience size changes dynamically

* **Steps:**

  1. Validate request
  2. Remove room viewers before winner selection

* **Expected Result:**

  * Graceful handling
  * No invalid winner assignment

* **Why it matters:**
  Prevents reward allocation bugs.

---

### TC-22: Verify sender cannot receive reward as winner (spec clarification)

* **Category:** Business logic

* **Priority:** P2

* **Preconditions:** Sender inside room audience

* **Steps:**

  1. Send request

* **Expected Result:**

  * Behavior follows product rule (allowed or excluded)

* **Why it matters:**
  Identifies unclear reward logic.

---

### TC-23: Duplicate winners are not selected

* **Category:** Business logic

* **Priority:** P1

* **Preconditions:** Room has enough viewers

* **Steps:**

  1. Send request with multiple winners

* **Expected Result:**

  * Winners list contains unique users only

* **Why it matters:**
  Prevents unfair reward duplication.

---

## 7. Side Effects

### TC-24: Verify WebSocket event broadcast after successful gift send

* **Category:** Side effects

* **Priority:** P1

* **Preconditions:** Valid request

* **Steps:**

  1. Send successful request
  2. Listen to room channel

* **Expected Result:**

  * `gift.sent` event emitted once
  * Correct transaction data included

* **Why it matters:**
  Ensures real-time UI synchronization.

---

### TC-25: Database rollback when reward crediting fails

* **Category:** Side effects

* **Priority:** P0

* **Preconditions:** Simulate DB failure while rewarding winners

* **Steps:**

  1. Trigger request
  2. Force failure during winner coin update

* **Expected Result:**

  * Entire DB transaction rolled back
  * Sender balance unchanged
  * No partial transaction persisted

* **Why it matters:**
  Prevents money inconsistency.

---

## 8. Negative / Security

### TC-26: SQL injection attempt in room_id

* **Category:** Security

* **Priority:** P1

* **Preconditions:** Valid auth token

* **Steps:**

  1. Send `"room_id": "1 OR 1=1"`

* **Expected Result:**

  * Request rejected (`422`)
  * No unexpected DB behavior

* **Why it matters:**
  Prevents injection vulnerabilities.

---

### TC-27: Send extremely large payload values

* **Category:** Security

* **Priority:** P1

* **Preconditions:** Valid token

* **Steps:**

  1. Send `quantity = 99999999`

* **Expected Result:**

  * Validation rejects request
  * No overflow or server crash

* **Why it matters:**
  Prevents abuse and integer overflow issues.

---

## Spec Ambiguities / Clarifications

1. Should sender be eligible to win from their own gift?
2. What exact response should duplicate `idempotency_key` return? (`200`, cached response, or `409`?)
3. How should audience changes during request execution be handled? Snapshot or real-time audience?
4. What happens if wallet top-up webhook and gift send occur at the exact same time?
