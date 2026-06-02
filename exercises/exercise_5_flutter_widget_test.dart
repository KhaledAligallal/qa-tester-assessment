// =============================================================================
// EXERCISE 5: Flutter Widget Test — Login Form
// Time: 30 minutes  |  Points: 20  |  Type: Code (Dart + flutter_test)
// =============================================================================
//
// SCENARIO:
// Below is a real-world LoginForm widget from our app. It has zero tests.
// Your job is to write widget tests using `flutter_test` that pin down its
// behavior so a future refactor cannot break it silently.
//
// TASKS (write your tests at the bottom of this file inside the `void main()`
// block — do NOT modify the LoginForm widget itself):
//
// 1. [All Levels] Test that the form renders both fields and the submit button.
// 2. [All Levels] Test that tapping submit with empty fields shows two
//    validation error messages.
// 3. [Mid+] Test that entering an invalid email (e.g., "notanemail") shows the
//    email validation error.
// 4. [Mid+] Test that entering valid email + password calls AuthService.login()
//    exactly once with those credentials.
//      → Use a mock/fake for AuthService. You may add `mocktail` or `mockito` to
//        pubspec.yaml. If you don't want to add a dep, write a manual fake.
// 5. [Mid+] Test that while AuthService.login() is in-flight, the submit button
//    is disabled AND a CircularProgressIndicator is shown.
// 6. [Senior] Test that on a successful login, the onLoginSuccess callback is
//    called with the returned user_id.
// 7. [Senior] Test that on a 401 response, an error SnackBar is shown with the
//    text "Invalid credentials".
//
// RULES:
// - Use `testWidgets` and `pumpWidget`. No integration_test required.
// - You may add helper functions / a test harness at the top of `main()`.
// - You may add packages to a hypothetical pubspec.yaml — list them in a
//   comment at the top of this file.
// - You do NOT need to actually run `flutter test` — we evaluate the code.
//   But a passing run + green output pasted as a comment is a bonus.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// SERVICE CONTRACT (do not modify — your tests will mock this)
// ---------------------------------------------------------------------------

abstract class AuthService {
  /// Returns user_id on success, throws [AuthException] on failure.
  Future<int> login({required String email, required String password});
}

class AuthException implements Exception {
  final int statusCode;
  final String message;
  AuthException(this.statusCode, this.message);
}

// ---------------------------------------------------------------------------
// WIDGET UNDER TEST (do not modify)
// ---------------------------------------------------------------------------

class LoginForm extends StatefulWidget {
  final AuthService authService;
  final void Function(int userId) onLoginSuccess;

  const LoginForm({
    super.key,
    required this.authService,
    required this.onLoginSuccess,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    final emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRe.hasMatch(v)) return 'Invalid email format';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final userId = await widget.authService.login(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
      widget.onLoginSuccess(userId);
    } on AuthException catch (e) {
      if (!mounted) return;
      final message = e.statusCode == 401 ? 'Invalid credentials' : e.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            key: const Key('email_field'),
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: _validateEmail,
          ),
          TextFormField(
            key: const Key('password_field'),
            controller: _passwordCtrl,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            validator: _validatePassword,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            key: const Key('submit_button'),
            onPressed: _loading ? null : _onSubmit,
            child: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Log in'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TODO (candidate): write your tests below
// ---------------------------------------------------------------------------

void main() {
  // TODO: define a fake AuthService (or use a mocking library).
  // TODO: write all 7 tests listed in the TASKS comment at the top.
  //
  // Example skeleton:
  //
  //   testWidgets('renders email + password fields + submit button', (tester) async {
  //     await tester.pumpWidget(...);
  //     expect(find.byKey(const Key('email_field')), findsOneWidget);
  //     ...
  //   });
}

/*
=============================================================================
SUBMISSION NOTES
=============================================================================

At the top of this file, in a comment block, list:
  - Any packages you'd add to pubspec.yaml (e.g., mocktail: ^1.0.0)
  - Any helper functions / test harness you created and why

If you ran `flutter test`, paste the green output here at the bottom.

=============================================================================
EVALUATION CRITERIA
=============================================================================

| Criterion                       | Points | What We Look For
|---------------------------------|--------|----------------------------------------
| All 7 test cases written        | 7      | One testWidgets per requirement
| Mock / fake AuthService         | 3      | Proper isolation — no real network calls
| Loading-state test              | 3      | Uses pump (no duration) to catch the in-flight frame
| onLoginSuccess callback         | 2      | Verifies the exact userId was passed
| SnackBar 401 test               | 3      | Pumps after error, finds the exact text
| Test independence + cleanup     | 2      | No shared mutable state between tests

=============================================================================
*/
