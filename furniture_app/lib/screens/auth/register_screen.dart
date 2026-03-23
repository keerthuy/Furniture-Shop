import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _obscure = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    // 🔥 Auto convert 07XXXXXXXX → +947XXXXXXXX
    String phone = _phoneCtrl.text.trim();
    if (phone.startsWith('0')) {
      phone = phone.replaceFirst('0', '+94');
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
      phone,
      _addressCtrl.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/main');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Registration failed'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Sign Up',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.dark),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fill in your details to get started',
                style: TextStyle(color: AppTheme.grey),
              ),
              const SizedBox(height: 28),

              // 🔹 Name (unchanged as requested)
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter your name' : null,
              ),

              const SizedBox(height: 14),

              // 🔹 Email
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter email';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(v)) {
                    return 'Enter valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // 🔹 Password
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter password';
                  if (v.length < 6) return 'Minimum 6 characters';
                  if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)')
                      .hasMatch(v)) {
                    return 'Must include letters and numbers';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // 🔹 Phone (Sri Lanka 🇱🇰)
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(12),
                ],
                decoration: const InputDecoration(
                  labelText: 'Phone (+94 or 07)',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Enter phone number';
                  }

                  final phone = v.replaceAll(' ', '');

                  if (!RegExp(r'^(?:\+94|0)7[0-9]{8}$')
                      .hasMatch(phone)) {
                    return 'Enter valid Sri Lankan number';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              // 🔹 Address
              TextFormField(
                controller: _addressCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter your address';
                  }
                  if (v.trim().length < 10) {
                    return 'Address too short';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _register,
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Create Account'),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: AppTheme.grey),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}