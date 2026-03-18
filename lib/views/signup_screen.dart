import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';
import '../viewmodels/auth_viewmodel.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    if (authViewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authViewModel.errorMessage!), backgroundColor: AppColors.error),
        );
        authViewModel.clearError();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('CineBook'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              
              // Custom Login / Sign Up Tab Mock
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => context.pushReplacement('/login'),
                    child: Text('Login', style: TextStyle(fontWeight: FontWeight.normal, color: AppColors.textSecondary, fontSize: 18)),
                  ),
                  const SizedBox(width: 32),
                  Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 48),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'John Doe',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'you@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+94 77 123 4567',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(value: false, onChanged: (v){}),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        children: [
                          TextSpan(text: 'I agree to the '),
                          TextSpan(text: 'Terms of Service', style: TextStyle(color: AppColors.primary)),
                          TextSpan(text: ' and '),
                          TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: authViewModel.isLoading 
                  ? null 
                  : () async {
                      if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
                         return;
                      }
                      final success = await authViewModel.signUp(
                        _nameController.text.trim(),
                        _emailController.text.trim(), 
                        _passwordController.text.trim()
                      );
                      if (success && mounted) {
                        context.go('/home');
                      }
                  },
                child: authViewModel.isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
