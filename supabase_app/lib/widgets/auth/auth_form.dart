import 'package:flutter/material.dart';
import '../common/custom_text_field.dart';
import '../../components/custom_button.dart';

class AuthForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isSignUp;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onToggleMode;

  const AuthForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isSignUp,
    required this.isLoading,
    required this.onSubmit,
    required this.onToggleMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: emailController,
          labelText: 'Email',
          keyboardType: TextInputType.emailAddress,
          focusedBorderColor: const Color(0xFF667eea),
          fillColor: Colors.white.withOpacity(0.1),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: passwordController,
          labelText: 'Password',
          obscureText: true,
          focusedBorderColor: const Color(0xFF667eea),
          fillColor: Colors.white.withOpacity(0.1),
        ),
        const SizedBox(height: 24),
        CustomGradientButton(
          text: isSignUp ? 'Sign Up' : 'Sign In',
          width: double.infinity,
          onPressed: isLoading ? null : onSubmit,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: onToggleMode,
          child: Text(
            isSignUp
                ? 'Already have an account? Sign In'
                : 'Don\'t have an account? Sign Up',
            style: const TextStyle(color: Color(0xFF667eea)),
          ),
        ),
      ],
    );
  }
}