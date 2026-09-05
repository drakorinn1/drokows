import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_config.dart';

class AuthState extends ChangeNotifier {
  User? _user;
  bool _initialized = false;

  AuthState() {
    _user = supabase.auth.currentSession?.user;
    _initialized = true;
    supabase.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  bool get initialized => _initialized;
  bool get isSignedIn => _user != null;
  User? get user => _user;

  String? get displayName =>
      (_user?.userMetadata?['name'] as String?) ?? _user?.email;

  Future<String?> signIn({required String email, required String password}) async {
    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Giriş yapılamadı. Lütfen tekrar deneyin.';
    }
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Kayıt oluşturulamadı. Lütfen tekrar deneyin.';
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}