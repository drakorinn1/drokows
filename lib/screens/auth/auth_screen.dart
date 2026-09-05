import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_state.dart';
import '../../theme/app_theme.dart';

enum AuthMode { signIn, signUp }

class AuthScreen extends StatefulWidget {
  final AuthMode initialMode;
  const AuthScreen({super.key, this.initialMode = AuthMode.signIn});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthMode _mode = widget.initialMode;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  bool get _isSignUp => _mode == AuthMode.signUp;

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    final auth = context.read<AuthState>();
    final error = _isSignUp
        ? await auth.signUp(
            name: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
          )
        : await auth.signIn(email: _emailCtrl.text.trim(), password: _passwordCtrl.text);

    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = error;
    });
    // Başarılı girişte AuthState değişir ve kök widget otomatik olarak
    // ana ekrana yönlendirir (bkz. main.dart / AuthGate).
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.handyman_rounded, color: AppColors.primaryForeground, size: 28),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isSignUp ? "Ustam'a kayıt ol" : 'Tekrar hoş geldin',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isSignUp
                        ? 'Dakikalar içinde güvenilir usta bulmaya başla.'
                        : 'Hesabına giriş yap ve usta çağırmaya devam et.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13.5, color: AppColors.mutedForeground),
                  ),
                  const SizedBox(height: 28),
                  if (_isSignUp) ...[
                    const _FieldLabel('Ad Soyad'),
                    TextField(
                      controller: _nameCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(hintText: 'Örn. Ahmet Yılmaz'),
                    ),
                    const SizedBox(height: 14),
                  ],
                  const _FieldLabel('E-posta'),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(hintText: 'ornek@eposta.com'),
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel('Şifre'),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _loading ? null : _submit(),
                    decoration: const InputDecoration(hintText: 'En az 8 karakter'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: AppColors.destructive, fontSize: 13.5)),
                  ],
                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: Text(_loading ? 'Lütfen bekleyin...' : (_isSignUp ? 'Kayıt ol' : 'Giriş yap')),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() {
                        _mode = _isSignUp ? AuthMode.signIn : AuthMode.signUp;
                        _error = null;
                      }),
                      child: Text.rich(
                        TextSpan(
                          text: _isSignUp ? 'Zaten hesabın var mı? ' : 'Hesabın yok mu? ',
                          style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13.5),
                          children: [
                            TextSpan(
                              text: _isSignUp ? 'Giriş yap' : 'Kayıt ol',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
    );
  }
}
