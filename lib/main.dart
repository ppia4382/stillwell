import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stillwell/features/provider/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");

    //Start the App with Riverpod state management
    runApp(
      const ProviderScope(
        child: StillWell(),
      ),
    );
  } catch (e) {
    // Fallback UI if .env or startup fails
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text("Startup Failed: $e\nCheck if .env is in root.")),
        ),
      ),
    );
  }
}

class StillWell extends ConsumerWidget {
  const StillWell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to the auth state (loading, error, or success)
    final authState = ref.watch(authProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text("StillWell Setup")),
        body: Center(
          child: authState.when(
            loading: () => const CircularProgressIndicator(),
            error: (err, stack) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                Text('Auth Error: $err'),
                ElevatedButton(
                  onPressed: () => ref.read(authProvider.notifier).login(),
                  child: const Text("Retry Login"),
                )
              ],
            ),
            data: (code) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (code == null) ...[
                  const Text("Welcome to StillWell", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => ref.read(authProvider.notifier).login(),
                    child: const Text("Connect Fitbit / Fitbitに接続"),
                  ),
                ] else ...[
                  const Icon(Icons.check_circle, color: Colors.green, size: 60),
                  const SizedBox(height: 10),
                  const Text("Connection Successful!", style: TextStyle(fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("Auth Code: $code", textAlign: TextAlign.center),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}