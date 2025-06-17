import 'package:ecom/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:ecom/components/login_signup/login_signup_comps.dart';
import 'package:ecom/pages/login_page.dart';
import 'package:ecom/services/auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController(); // Changed to first name
  final _lastNameController = TextEditingController();  // Added last name
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose(); // Updated
    _lastNameController.dispose();  // Added
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  void _showError(String message) {
    print('Signup error: $message');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Something went wrong. Please try again.'),
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

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final firstName = _firstNameController.text.trim();
        final lastName = _lastNameController.text.trim();

        // Validate that we have first name
        if (firstName.isEmpty) {
          throw Exception('Please enter your first name');
        }
        
        final response = await _authService.signup(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: firstName,
          lastName: lastName.isEmpty ? ' ' : lastName, // Ensure lastName is not empty
          phoneNumber: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          context: context, // Pass context to initialize user provider
        );

        _showSuccess(response.message);
        
        // No need to manually store user data as AuthService._saveUserData already handles this
        // Navigate to home page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePageBase()),
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
                  hintText: 'First Name',
                  prefixIcon: Icons.person_outline,
                  controller: _firstNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  hintText: 'Last Name',
                  prefixIcon: Icons.person_outline,
                  controller: _lastNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
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
                  hintText: 'Phone Number',
                  prefixIcon: Icons.phone_outlined,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      // Simple validation for phone number - can be enhanced
                      if (value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
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
