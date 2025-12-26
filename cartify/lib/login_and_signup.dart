import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'colors.dart';
import 'reset_password.dart';
import 'database_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'otp_verification.dart';

// 1.__Splash Screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // ✅ CONSTANT: Page ID for Colors (Shared with Login)
  final String pageId = 'LOGIN';

  @override
  void initState() {
    super.initState();

    // Animation setup
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Navigate to Home after 4 seconds
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            gradient: AppGradients.splashBackgroundForPage(
                pageId)), // ✅ UPDATED
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/glass-logo.png', height: 150),

                Text(
                  " CARTIFY",
                  style: TextStyle(
                    fontSize: 35,
                    fontFamily: 'IrishGrover',
                    letterSpacing: 2,
                    color: AppColors.getAccentForPage(pageId), // ✅ UPDATED
                  ),
                ),
                const SizedBox(height: 30),
                SpinKitThreeBounce(
                    color: AppColors.getAccentForPage(pageId),
                    size: 25.0), // ✅ UPDATED
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 2.__Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // ✅ CONSTANT: Page ID for Colors
  final String pageId = 'LOGIN';

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter email and password'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Check if email is verified in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      final isEmailVerified = userDoc.data()?['emailVerified'] ?? false;

      setState(() {
        _isLoading = false;
      });

      if (!isEmailVerified) {
        // Email not verified, navigate to OTP screen
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                email: emailController.text.trim(),
                userId: userCredential.user!.uid,
              ),
            ),
                (route) => false,
          );
        }
      } else {
        // Email verified, proceed to home
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundForPage(pageId), // ✅ UPDATED
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 42),
          color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppGradients.splashBackgroundForPage(
                    pageId), // ✅ UPDATED
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Login",
                    style: TextStyle(
                      fontFamily: 'IrishGrover',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimaryForPage(
                          pageId), // ✅ UPDATED
                    ),
                  ),
                  SizedBox(height: 20),
                  Image.asset('assets/images/glass-logo.png', height: 150),
                ],
              ),
            ),

            const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    " Enter your Email",
                    style: TextStyle(
                      color: AppColors.getTextPrimaryForPage(
                          pageId), // ✅ UPDATED
                      fontFamily: 'ADLaMDisplay',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                        color: AppColors.getTextPrimaryForPage(
                            pageId)), // ✅ UPDATED
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                            color: AppColors.getBorderForPage(
                                pageId)), // ✅ UPDATED
                      ),
                      labelText: 'Email',
                      labelStyle: TextStyle(
                          color: AppColors.getTextSecondaryForPage(
                              pageId)), // ✅ UPDATED
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    " Enter your password",
                    style: TextStyle(
                      color: AppColors.getTextPrimaryForPage(
                          pageId), // ✅ UPDATED
                      fontFamily: 'ADLaMDisplay',
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: !_isPasswordVisible,
                    style: TextStyle(
                        color: AppColors.getTextPrimaryForPage(
                            pageId)), // ✅ UPDATED
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                          color: AppColors.getTextSecondaryForPage(
                              pageId)), // ✅ UPDATED
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                            color: AppColors.getBorderForPage(
                                pageId)), // ✅ UPDATED
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.getTextSecondaryForPage(
                              pageId), // ✅ UPDATED
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 5, right: 15),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "forgot password?",
                    style: TextStyle(
                      color:
                      AppColors.getAccentForPage(pageId), // ✅ UPDATED
                      fontFamily: 'ADLaMDisplay',
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.getAccentForPage(
                        pageId), // ✅ UPDATED
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'ADLaMDisplay',
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(
                    color: AppColors.getTextPrimaryForPage(
                        pageId), // ✅ UPDATED
                    fontFamily: 'ADLaMDisplay',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimaryForPage(
                          pageId), // ✅ UPDATED
                      fontFamily: 'ADLaMDisplay',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 3.__Sign Up Screen
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  // ✅ CONSTANT: Page ID for Colors
  final String pageId = 'LOGIN';

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Email validation function
  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }

    // Basic email format validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }

    // Check for common disposable/temporary email domains
    final disposableDomains = [
      'tempmail.com',
      '10minutemail.com',
      'guerrillamail.com',
      'mailinator.com',
      'trashmail.com',
      'throwaway.email',
      'fakeinbox.com',
      'maildrop.cc',
      'temp-mail.org',
      'getnada.com',
    ];

    final domain = email.split('@').last.toLowerCase();
    if (disposableDomains.contains(domain)) {
      return 'Please use a permanent email address';
    }

    // Check for suspicious patterns
    if (email.contains('..') || email.startsWith('.') || email.endsWith('.')) {
      return 'Invalid email format';
    }

    return null; // Email is valid
  }

  // Password validation function
  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (password.length > 11) {
      return 'Password must not exceed 11 characters';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one capital letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null; // Password is valid
  }

  Future<void> _signUp() async {
    // Validate all fields
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate email
    String? emailError = _validateEmail(emailController.text.trim());
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emailError),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Validate password with new rules
    String? passwordError = _validatePassword(passwordController.text);
    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(passwordError),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Check if passwords match
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user with Firebase Auth
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Create user document in Firestore
      await DatabaseService.instance.createUser(
        uid: userCredential.user!.uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Initialize reward points
      await DatabaseService.instance.setRewardPoints(
        userCredential.user!.uid,
        0,
      );

      setState(() {
        _isLoading = false;
      });

      // Navigate to OTP verification screen
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              email: emailController.text.trim(),
              userId: userCredential.user!.uid,
            ),
          ),
              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      String message = 'Sign up failed';
      if (e.code == 'weak-password') {
        message = 'The password is too weak';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for this email';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundForPage(pageId), // ✅ UPDATED
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 42),
          color: AppColors.getTextPrimaryForPage(pageId), // ✅ UPDATED
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppGradients.splashBackgroundForPage(
                    pageId), // ✅ UPDATED
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Register",
                    style: TextStyle(
                      fontFamily: 'IrishGrover',
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimaryForPage(
                          pageId), // ✅ UPDATED
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset('assets/images/glass-logo.png', height: 150),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    " Enter Name",
                    style: TextStyle(
                      color: AppColors.getTextPrimaryForPage(
                          pageId), // ✅ UPDATED
                      fontFamily: 'ADLaMDisplay',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    style: TextStyle(
                        color: AppColors.getTextPrimaryForPage(
                            pageId)), // ✅ UPDATED
                    decoration: InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(
                          color: AppColors.getTextSecondaryForPage(
                              pageId)), // ✅ UPDATED
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                            color: AppColors.getBorderForPage(
                                pageId)), // ✅ UPDATED
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    " Enter Email",
                    style: TextStyle(
                      color: AppColors.getTextPrimaryForPage(
                          pageId), // ✅ UPDATED
                      fontFamily: 'ADLaMDisplay',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                        color: AppColors.getTextPrimaryForPage(
                            pageId)), // ✅ UPDATED
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(
                          color: AppColors.getTextSecondaryForPage(
                              pageId)), // ✅ UPDATED
                      helperText: "Use a valid, permanent email address",
                      helperStyle: TextStyle(
                        color: AppColors.getTextSecondaryForPage(
                            pageId), // ✅ UPDATED
                        fontSize: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                            color: AppColors.getBorderForPage(
                                pageId)), // ✅ UPDATED
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    " Enter Password",
                    style: TextStyle(
                      color: AppColors.getTextPrimaryForPage(
                          pageId), // ✅ UPDATED
                      fontFamily: 'ADLaMDisplay',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: !_isPasswordVisible,
                    maxLength: 11,
                    style: TextStyle(
                        color: AppColors.getTextPrimaryForPage(
                            pageId)), // ✅ UPDATED
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(
                          color: AppColors.getTextSecondaryForPage(
                              pageId)), // ✅ UPDATED
                      helperText: "6-11 chars, 1 capital, 1 number",
                      helperStyle: TextStyle(
                        color: AppColors.getTextSecondaryForPage(
                            pageId), // ✅ UPDATED
                        fontSize: 12,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                            color: AppColors.getBorderForPage(
                                pageId)), // ✅ UPDATED
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.getTextSecondaryForPage(
                              pageId), // ✅ UPDATED
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    " Confirm Password",
                    style: TextStyle(
                      color: AppColors.getTextPrimaryForPage(
                          pageId), // ✅ UPDATED
                      fontFamily: 'ADLaMDisplay',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    maxLength: 11,
                    style: TextStyle(
                        color: AppColors.getTextPrimaryForPage(
                            pageId)), // ✅ UPDATED
                    decoration: InputDecoration(
                      hintText: "Re-enter your password",
                      hintStyle: TextStyle(
                          color: AppColors.getTextSecondaryForPage(
                              pageId)), // ✅ UPDATED
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                            color: AppColors.getBorderForPage(
                                pageId)), // ✅ UPDATED
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.getTextSecondaryForPage(
                              pageId), // ✅ UPDATED
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.getAccentForPage(
                        pageId), // ✅ UPDATED
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isLoading ? null : _signUp,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'ADLaMDisplay',
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account?",
                  style: TextStyle(
                    color: AppColors.getTextPrimaryForPage(
                        pageId), // ✅ UPDATED
                    fontFamily: 'ADLaMDisplay',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Log In",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimaryForPage(
                          pageId), // ✅ UPDATED
                      fontFamily: 'ADLaMDisplay',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}