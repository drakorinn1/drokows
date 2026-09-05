import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/root_shell.dart';
import 'services/supabase_config.dart';
import 'state/auth_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  runApp(const UstamApp());
}

class UstamApp extends StatelessWidget {
  const UstamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthState(),
      child: MaterialApp(
        title: 'Ustam · Güvenilir usta bul',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: const AuthGate(),
      ),
    );
  }
}

/// app/page.tsx, app/sign-in/page.tsx vb. dosyalardaki
/// `if (!session?.user) redirect("/sign-in")` mantığının karşılığı.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    if (!auth.isSignedIn) {
      return const AuthScreen();
    }
    return const RootShell();
  }
}
