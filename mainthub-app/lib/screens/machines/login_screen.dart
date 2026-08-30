import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import 'dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey       = GlobalKey<FormState>();
  final _emailCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  bool  _obscurePass   = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth    = context.read<AuthProvider>();
    final success = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error.isNotEmpty ? auth.error : 'Login failed'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo Container
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.build_circle_rounded,
                    size: 48,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'MainHub',
                  style: textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Maintenance Management System',
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Form Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome Back',
                            style: textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          // Email
                          TextFormField(
                            controller:   _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration:   const InputDecoration(
                              labelText:  'Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            validator: (v) =>
                                v == null || !v.contains('@') ? 'Enter a valid email' : null,
                          ),
                          const SizedBox(height: 16),
                          // Password
                          TextFormField(
                            controller:    _passwordCtrl,
                            obscureText:   _obscurePass,
                            decoration: InputDecoration(
                              labelText:  'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePass
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () => setState(() => _obscurePass = !_obscurePass),
                              ),
                            ),
                            validator: (v) =>
                                v == null || v.length < 6 ? 'Password too short' : null,
                          ),
                          const SizedBox(height: 32),
                          // Login button
                          auth.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _login,
                                  child: const Text('Login'),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Sign Up Option
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: textTheme.bodyMedium?.copyWith(color: AppTheme.textLight),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      ),
                      child: Text(
                        'Sign Up',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
