import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stillwell/features/provider/auth_provider.dart'
    show AuthNotifier, authProvider;
import 'package:stillwell/features/routine_check/data/datasources/fitbit_remote_datasource.dart'
    show FitbitRemoteDatasource;
import 'package:stillwell/main.dart';

// "Fake" Notifier for the test
class FakeAuthNotifier extends AuthNotifier {
  // Initialize directly into the "Ready" state with no token
  FakeAuthNotifier() : super(FitbitRemoteDatasource()) {
    state = const AsyncValue.data(null);
  }

  @override
  Future<void> loadSession() async {
    // Do nothing so it doesn't try to touch SecureStorage or DotEnv
  }
}

void main() {
  testWidgets('StillWell shows welcome text when no token is found', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // "Intercept" the provider and swap the real one for the Fake
          authProvider.overrideWith((ref) => FakeAuthNotifier()),
        ],
        child: const StillWell(),
      ),
    );

    // Render the frame
    await tester.pump();

    // Verify the UI reacted to the Fake state
    expect(find.text("Welcome to StillWell"), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}