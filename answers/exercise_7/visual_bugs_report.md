# Visual Bugs Report — Admin Panel (Mock)

**Total Bugs Found:** 10

---

## Severity Scale

| Level | Meaning |
|---|---|
| 🔴 Critical | Security breach, data loss, or completely broken flow |
| 🟠 High | Major feature broken or wrong data shown |
| 🟡 Medium | Feature works but incorrectly or confusingly |
| 🟢 Low | Minor UX/cosmetic issue |

---

## BUG-01 · Incorrect Total Coins Calculation

- **Where:** Gift / Coins total cost section
- **Category:** Business Logic
- **Severity:** 🟠 High
- **Reasoning:** Affects financial calculations and may lead to incorrect charging.

**Steps to Reproduce:**
1. Select a number of coins or gifts.
2. Observe the total cost calculation.
3. Change the quantity and recheck the result.

**Expected:**
Total cost should be calculated as: `price × quantity`

**Actual:**
The system adds values instead of multiplying, resulting in an incorrect total cost.

**Root Cause Hypothesis:**
Frontend business logic issue — `+` operator used instead of `*`.

**Fix Suggestion:**
Replace addition logic with multiplication logic for the total calculation.

---

## BUG-02 · Missing Input Validation

- **Where:** Form inputs across the application
- **Category:** Form Validation
- **Severity:** 🟠 High
- **Reasoning:** Leads to invalid data being stored in the system.

**Steps to Reproduce:**
1. Open any form.
2. Enter invalid, empty, or incorrect values.
3. Submit the form.

**Expected:**
Input validation should prevent invalid data and show inline error messages.

**Actual:**
The system accepts invalid or empty inputs without any warnings.

**Root Cause Hypothesis:**
Missing frontend validation — no `required` checks or format validators on input fields.

**Fix Suggestion:**
Add required field validation, format checks, and proper error messages per field.

---

## BUG-03 · UI Broken with Long Text Input

- **Where:** Username display / tables / lists
- **Category:** Layout / UX
- **Severity:** 🟡 Medium
- **Reasoning:** Affects UI only, no functional impact.

**Steps to Reproduce:**
1. Enter a very long username.
2. Display it in a table or list.

**Expected:**
Long text should be truncated or wrapped properly without breaking the layout.

**Actual:**
The UI layout breaks and content overflows outside its container.

**Root Cause Hypothesis:**
CSS handling issue — no `max-width`, `overflow`, or `text-overflow` set on the table cell.

**Fix Suggestion:**
Apply `text-overflow: ellipsis` with `overflow: hidden` and `max-width` on the username cell. Also add `maxLength` validation on the input field to prevent excessively long usernames from being created.

---

## BUG-04 · Unauthorized Ban Action on Admin Users

- **Where:** Admin panel → Users → Ban action
- **Category:** Authorization / Security
- **Severity:** 🔴 Critical
- **Reasoning:** Security and authorization issue affecting system integrity — an admin could ban all other admins, locking everyone out.

**Steps to Reproduce:**
1. Login as Admin.
2. Navigate to the Users table.
3. Find another admin user.
4. Click the Ban button.

**Expected:**
Admin users should not be banneable — the Ban button should be hidden or disabled for any account with the admin role (RBAC restriction).

**Actual:**
The system allows banning admin users without any restriction.

**Root Cause Hypothesis:**
Missing role-based access control check before rendering the Ban button. No backend authorization guard on the ban endpoint either.

**Fix Suggestion:**
Implement RBAC on both frontend (hide/disable Ban for admin roles) and backend (reject ban requests targeting admin accounts).

---

## BUG-05 · Balance and Transaction History Mismatch

- **Where:** Wallet / Balance section
- **Category:** Money / Numbers
- **Severity:** 🔴 Critical
- **Reasoning:** Financial data inconsistency — users and admins cannot trust the displayed balance.

**Steps to Reproduce:**
1. Check current balance (shows 10,000).
2. Note the last transaction: Refund +500 → Balance after: 10,500.
3. Observe that the displayed current balance (10,000) does not match the last recorded balance (10,500).

**Expected:**
Current balance should match the "Balance after" value of the most recent transaction → **10,500**.

**Actual:**
Current balance shows **10,000** — a discrepancy of 500 coins.

**Root Cause Hypothesis:**
State synchronization issue — the balance display is fetched separately from the transaction list and was not refreshed after the last transaction was recorded.

**Fix Suggestion:**
Ensure a single source of truth for balance calculation, preferably backend-driven. Re-fetch the balance after every transaction, or derive it directly from the last transaction's "Balance after" field.

---

## BUG-06 · Missing Popup for Ban Reason Input

- **Where:** Ban user flow
- **Category:** State / UX
- **Severity:** 🟠 High
- **Reasoning:** Breaks the expected workflow and affects auditability — bans with no reason cannot be reviewed or disputed.

**Steps to Reproduce:**
1. Click the Ban button on any user.
2. Observe that no popup or modal appears.
3. Notice the ban is executed immediately.

**Expected:**
A modal should appear requesting a reason before the ban is executed.

**Actual:**
Ban is executed instantly without prompting for a reason.

**Root Cause Hypothesis:**
The frontend modal was either not implemented or its trigger condition is skipped in the current flow.

**Fix Suggestion:**
Enforce a modal input step before firing the ban API request. The reason field should be required — the confirm button stays disabled until a reason is entered.

---

## BUG-07 · Ban Reason Missing in Flow but Appears in Table

- **Where:** Ban workflow + Bans table
- **Category:** State / Data
- **Severity:** 🟠 High
- **Reasoning:** Data inconsistency — a reason appears in the table even though the user was never asked to provide one, suggesting phantom or auto-generated data.

**Steps to Reproduce:**
1. Trigger a ban action.
2. Confirm that no reason input popup appeared.
3. Navigate to the Bans table and check the reason column.

**Expected:**
Reason should be explicitly provided by the user before the ban is executed.

**Actual:**
No popup appears during the ban flow, but a reason still appears in the Bans table afterward.

**Root Cause Hypothesis:**
Backend is auto-injecting a default or hardcoded reason string when none is provided, creating a false impression that a reason was entered.

**Fix Suggestion:**
Require explicit reason input from the frontend before the API call is made. Remove any default/fallback reason injection on the backend.

---

## BUG-08 · Missing Pagination, Sorting, and Search in Tables

- **Where:** All admin tables (Users / Transactions / Bans)
- **Category:** State / Data
- **Severity:** 🟡 Medium
- **Reasoning:** Impacts usability with larger datasets — tables become unmanageable without data management features.

**Steps to Reproduce:**
1. Open any data table (Users, Transactions, or Bans).
2. Try searching for a specific record.
3. Try sorting by any column.
4. Try navigating to a second page.

**Expected:**
Tables should support pagination, column sorting, and a search/filter input.

**Actual:**
Tables are static with no data management features — all records load at once with no way to search or sort.

**Root Cause Hypothesis:**
Pagination, sorting, and filtering were never implemented in the table components. The API likely fetches all records without `limit`/`offset` parameters.

**Fix Suggestion:**
Implement server-side pagination (`?page=1&limit=20`), sortable column headers, and a search input that filters by relevant fields. Add a record count display (e.g. "Showing 1–20 of 1,432").

---

## BUG-09 · No Visual Feedback for Balance Changes

- **Where:** Wallet / Balance update section
- **Category:** Layout / UX
- **Severity:** 🟢 Low
- **Reasoning:** UX improvement only, no functional impact.

**Steps to Reproduce:**
1. Perform any transaction (add or subtract coins).
2. Observe the balance and the Amount column in the transactions table.

**Expected:**
Positive amounts displayed in green, negative amounts in red — standard financial UI convention.

**Actual:**
All amounts are displayed in the same default text color regardless of direction.

**Root Cause Hypothesis:**
No conditional styling applied to the amount cell based on the sign of the value.

**Fix Suggestion:**
```jsx
<td style={{ color: amount > 0 ? '#16a34a' : '#dc2626' }}>
  {amount > 0 ? `+${amount}` : amount}
</td>
```

---

## BUG-10 · JavaScript Console Error When Triggering Gift Action

- **Where:** Gift sending section / action button
- **Category:** Console Errors
- **Severity:** 🟡 Medium
- **Reasoning:** The feature relies on undefined data causing runtime errors. The app remains partially usable but the affected functionality may fail or produce incorrect results.

**Steps to Reproduce:**
1. Open the Admin Panel.
2. Navigate to the Gift section.
3. Perform the gift calculation or sending action.
4. Open DevTools → Console.

**Expected:**
The action executes successfully with no JavaScript errors.

**Actual:**
The console displays the following error repeatedly:
```
TypeError: Cannot read properties of undefined (reading 'coins')
```

**Root Cause Hypothesis:**
Frontend logic issue — the code attempts to access the `coins` property on an object that is `undefined` at the time of access, with no null/undefined check before the property read.

**Fix Suggestion:**
Add a null/undefined guard before accessing the property:
```js
const total = item?.coins ?? 0;
```
Add proper error handling for cases where the data is not yet loaded or is missing.

---



## How I Tested

I started by exploring all available sections of the application and interacting with every button and action to understand the overall functionality. I opened the browser DevTools during testing and reviewed both the Network and Console tabs. Initially, I focused on the Network tab, then noticed JavaScript errors appearing in the Console and investigated them further.

I tested different areas including form validation, UI behavior, business logic, wallet calculations, user management, and ban workflows. I also tried edge cases such as empty inputs, invalid values, and long text inputs to identify validation and layout issues.

After identifying the issues, I documented each bug with clear reproduction steps, expected and actual behavior, severity assessment, suspected root cause, and proposed fixes.
