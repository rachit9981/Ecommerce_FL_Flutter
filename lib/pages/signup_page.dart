import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecom/components/login_signup/login_signup_comps.dart';
import 'package:ecom/pages/login_page.dart';
import 'package:ecom/pages/home_page_main.dart';
import 'package:ecom/services/auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  List<String> _splitName(String fullName) {
    final parts = fullName.trim().split(' ');
    final firstName = parts.isNotEmpty ? parts[0] : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    return [firstName, lastName];
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final nameParts = _splitName(_nameController.text);
        final firstName = nameParts[0];
        final lastName = nameParts[1];

        // Validate that we have all required fields
        if (firstName.isEmpty) {
          throw Exception('Please enter at least a first name');
        }

        print('Sending signup data:');
        print('Email: ${_emailController.text.trim()}');
        print('Password: ${_passwordController.text.isNotEmpty ? "***" : "empty"}');
        print('First Name: $firstName');
        print('Last Name: $lastName');

        final response = await _authService.signup(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: firstName,
          lastName: lastName.isEmpty ? ' ' : lastName, // Ensure lastName is not empty
        );

        _showSuccess(response.message);
        
        // Store user data and token in shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', response.token);
        await prefs.setString('user_id', response.user.userId);
        await prefs.setString('user_email', response.user.email);
        await prefs.setString('user_first_name', response.user.firstName);
        await prefs.setString('user_last_name', response.user.lastName);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } catch (e) {
        _showError(e.toString().replaceFirst('Exception: ', ''));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageHeader(
                  title: 'Create Account',
                  subtitle: 'Sign up to get started',
                ),
                CustomTextField(
                  hintText: 'Full Name',
                  prefixIcon: Icons.person_outline,
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.trim().split(' ').isEmpty) {
                      return 'Please enter at least your first name';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  hintText: 'Email',
                  prefixIcon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  hintText: 'Confirm Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  controller: _confirmPasswordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: _isLoading ? 'Creating Account...' : 'Sign Up',
                  onPressed: _isLoading ? null : () {
                    _signup();
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: _isLoading ? null : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
