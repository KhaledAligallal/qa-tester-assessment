<?php

// =============================================================================
// EXERCISE 3: PHPUnit Feature Test — Sanctum-protected Gift Endpoint
// Time: 30 minutes  |  Points: 20  |  Type: Code (PHP)
// =============================================================================
//
// SCENARIO:
// A junior developer wrote a Laravel Feature test for the Send Gift endpoint
// described in Exercise 1 (live-stream gift with random audience bonus).
// The test "passes" but is full of bad practices, missing assertions, and
// skips several critical cases.
//
// THE ENDPOINT UNDER TEST:
//   POST /api/gifts/send  (auth:sanctum, throttle:30,1)
//   Body: { room_id, gift_id, quantity, winners_count, idempotency_key }
//   On success: deducts coins from sender wallet, credits winners, broadcasts
//   a WebSocket event, returns 200 with transaction_id + remaining_balance.
//
// YOUR TASKS:
// 1. [All Levels] Find and list the bugs/anti-patterns in this test in a
//    comment block at the top. Aim for at least 6.
// 2. [All Levels] Fix the test so that it would catch a regression where the
//    endpoint forgets to deduct coins from the sender's wallet.
// 3. [Mid+] Add three missing test methods:
//      a) test_returns_401_when_token_is_missing
//      b) test_returns_429_after_30_requests_in_one_minute
//      c) test_does_not_charge_sender_when_winners_count_exceeds_audience
// 4. [Mid+] Use Laravel factories instead of raw DB::table inserts.
// 5. [Senior] Refactor so the idempotency replay case (same idempotency_key
//    sent twice) is also tested and asserts the second call returns the
//    same transaction_id WITHOUT a second wallet debit.
// 6. [Senior] Add a test that uses Event::fake() to assert the broadcast
//    event 'gift.sent' was dispatched exactly once on success.
//
// RULES:
// - You may assume standard Laravel 10 + Sanctum 3 conventions.
// - You may add use statements, helper methods, or split into multiple test
//   classes if useful — explain why in a comment.
// - You do NOT need to actually run PHPUnit. We evaluate the code as written.
//   But if you DO run it, paste the green output as a comment at the bottom.
// =============================================================================

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Room;
use App\Models\Gift;
use App\Models\Wallet;
use Illuminate\Support\Facades\DB;

class SendGiftTest extends TestCase
{
    // BUG: missing `use RefreshDatabase;` — test pollutes the DB between runs

    public function test_it_works()
    {
        // BUG: vague test name — what behavior is being verified?

        // BUG: raw DB inserts instead of factories; brittle and bypasses model events
        DB::table('users')->insert([
            'id' => 1,
            'name' => 'Sender',
            'email' => 'sender@test.com',
            'password' => bcrypt('pass'),
        ]);
        DB::table('wallets')->insert(['user_id' => 1, 'coins' => 10000]);
        DB::table('rooms')->insert(['id' => 12345, 'owner_id' => 1, 'is_live' => 1]);
        DB::table('gifts')->insert(['id' => 7, 'name' => 'Rose', 'coin_price' => 500]);

        // BUG: hard-coded bearer token — not how Sanctum testing works
        $response = $this->withHeaders([
            'Authorization' => 'Bearer fake-token-123',
        ])->postJson('/api/gifts/send', [
            'room_id' => 12345,
            'gift_id' => 7,
            'quantity' => 10,
            'winners_count' => 5,
            'idempotency_key' => '11111111-1111-1111-1111-111111111111',
        ]);

        // BUG: only asserts status. Doesn't validate response body shape,
        // doesn't assert wallet was actually debited, doesn't assert winners
        // were credited, doesn't assert the transaction row was created.
        $response->assertStatus(200);

        // BUG: no assertion that the second-call idempotency works
        // BUG: no assertion that the broadcast event was dispatched
        // BUG: no cleanup — see missing RefreshDatabase above
    }

    // TODO (candidate): add the missing test methods listed in TASK 3 above.

    // TODO (candidate): add the idempotency replay test described in TASK 5.

    // TODO (candidate): add the Event::fake() broadcast-event test in TASK 6.
}

/*
=============================================================================
SUBMISSION FORMAT
=============================================================================

Rewrite this file in place with your fixes. At the top of the file, replace
this comment block with:

  // BUGS FOUND IN THE ORIGINAL TEST:
  // 1. ...
  // 2. ...
  // ...

  // REFACTOR NOTES:
  // - Used UserFactory + WalletFactory because ...
  // - Split SendGiftTest into ... and ... because ...

If you actually ran PHPUnit, paste the green output here at the bottom as a
comment.

=============================================================================
EVALUATION CRITERIA
=============================================================================

| Criterion                    | Points | What We Look For
|------------------------------|--------|----------------------------------
| Bugs identified              | 4      | At least 6 real bugs, listed clearly
| Wallet-debit regression test | 4      | A test that would FAIL if the code stopped charging the sender
| Auth + rate-limit tests      | 4      | Proper Sanctum::actingAs, throttle assertion
| Factories used correctly     | 3      | UserFactory, WalletFactory, RoomFactory etc.
| Idempotency replay test      | 3      | Asserts same transaction_id + only ONE wallet debit
| Event::fake() broadcast test | 2      | assertDispatched with exact event class

=============================================================================
*/
