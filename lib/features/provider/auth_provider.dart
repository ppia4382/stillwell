import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:stillwell/features/routine_check/data/datasources/fitbit_remote_datasource.dart';

// Provide the Datasource
final fitbitRemoteDataSourceProvider = Provider(
  (ref) => FitbitRemoteDatasource(),
);

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<String?>>((
  ref,
) {
  //Pass the datasource into the Notifier
  final datasource = ref.watch(fitbitRemoteDataSourceProvider);
  return AuthNotifier(datasource);
});

class AuthNotifier extends StateNotifier<AsyncValue<String?>> {
  final FitbitRemoteDatasource _datasource;
  final _storage = const FlutterSecureStorage();

  AuthNotifier(this._datasource) : super(const AsyncValue.loading()) {
    loadSession();
  }

  Future<void> loadSession() async {
    try {
      final savedToken = await _storage.read(key: 'fitbit_token');
      state = AsyncValue.data(savedToken);
    } catch (e, st) {
      _logError("Secure Storage Read Error", e, st);
      state = const AsyncValue.data(null);
    }
  }

  Future<void> login() async {
    state = const AsyncValue.loading();
    try {
      // Delegate the complex browser/URL logic to the datasource
      final code = await _datasource.getAuthCode();

      if (code != null) {
        await exchangeCodeForToken(code);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      _logError("Login Error", e, st);
      state = const AsyncValue.data(null);
    }
  }

  Future<void> exchangeCodeForToken(String code) async {
    state = const AsyncValue.loading();
    try {
      //Delegate the HTTP POST/Secret logic to the datasource
      final accessToken = await _datasource.exchangeCodeForToken(code);

      await _storage.write(key: 'fitbit_token', value: accessToken);
      state = AsyncValue.data(accessToken);
    } catch (e, st) {
      _logError("Token Exchange Error", e, st);
      state = const AsyncValue.data(null);
    }
  }

  void _logError(String message, dynamic e, StackTrace st) {
    dev.log(message, error: e, stackTrace: st, name: "STW.Auth");
  }
}