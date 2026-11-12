import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSigningIn = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 56,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Đăng nhập quản lý',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _emailController,
                    enabled: !_isSigningIn,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.username],
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      final email = (value ?? '').trim();
                      if (email.isEmpty || !email.contains('@')) {
                        return 'Nhập địa chỉ email hợp lệ.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    enabled: !_isSigningIn,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    onFieldSubmitted: (_) => _signIn(),
                    validator: (value) => (value ?? '').isEmpty
                        ? 'Vui lòng nhập mật khẩu.'
                        : null,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _isSigningIn ? null : _signIn,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: _isSigningIn
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Đăng nhập'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSigningIn = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthService>().signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() => _errorMessage = _firebaseErrorMessage(error));
      }
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = 'Đăng nhập thất bại: $error');
      }
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  String _firebaseErrorMessage(
    FirebaseAuthException error,
  ) => switch (error.code) {
    'invalid-email' => 'Địa chỉ email không hợp lệ.',
    'user-disabled' => 'Tài khoản này đã bị vô hiệu hóa.',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'Email hoặc mật khẩu không chính xác.',
    'too-many-requests' => 'Thử đăng nhập quá nhiều lần. Vui lòng thử lại sau.',
    'network-request-failed' => 'Không thể kết nối mạng. Hãy kiểm tra kết nối.',
    _ => error.message ?? 'Đăng nhập thất bại (${error.code}).',
  };
}
