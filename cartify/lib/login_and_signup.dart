import 'app_imports.dart';
import 'package:shimmer/shimmer.dart';
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

  final String pageId = 'LOGIN';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();

    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;

    // Check if user is logged in
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // No user logged in, go to home (guest mode)
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    try {
      // Check if email is verified in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final isEmailVerified = userDoc.data()?['emailVerified'] ?? false;

      if (!isEmailVerified) {
        // Email not verified, navigate to OTP screen
        final userEmail = userDoc.data()?['email'] ?? user.email ?? '';
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(
                email: userEmail,
                userId: user.uid,
                isNewUser: false,
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
    } catch (e) {
      // Error checking verification status, log out user and go to home
      print('Error checking email verification: $e');
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. THE BASE GRADIENT
          Container(
            decoration: BoxDecoration(
              gradient: AppGradients.splashBackgroundForPage(pageId),
            ),
          ),

          // 2. DECORATIVE BLURRED BLOBS (The "Modern" look)
          _buildBlurredBlob(top: -100, right: -50, color: Colors.white24),
          _buildBlurredBlob(
            bottom: -150,
            left: -100,
            color: AppColors.getAccentForPage(pageId).withOpacity(0.3),
          ),

          // 3. MAIN CONTENT
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Groups items tightly in the center
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Forces horizontal alignment
                  children: [
                    // 1. THE LOGO (Floating)
                    _buildFloatingLogo(),

                    // 3. THE TEXT
                    // 3. THE TEXT (Improved Shimmer with no black artifacts)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // LAYER A: THE STATIC SHADOW
                        // This provides the depth and glow without being affected by the shimmer mask
                        Text(
                          "  CARTIFY ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 45,
                            fontFamily: 'IrishGrover',
                            letterSpacing: 4,
                            color: Colors
                                .transparent, // We only want the shadow from this layer
                            shadows: [
                              Shadow(
                                blurRadius: 25,
                                color: AppColors.getAccentForPage(
                                  pageId,
                                ).withOpacity(0.4),
                                offset: const Offset(0, 8),
                              ),
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),

                        // LAYER B: THE SHIMMERING INK
                        // This layer handles the "light beam" moving across the letters
                        Shimmer.fromColors(
                          baseColor:
                              Colors.white, // Pure white base for clarity
                          highlightColor: AppColors.getAccentForPage(
                            pageId,
                          ).withOpacity(0.5), // Brand-colored glow
                          period: const Duration(milliseconds: 2500),
                          child: Text(
                            "  CARTIFY ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 45,
                              fontFamily: 'IrishGrover',
                              letterSpacing: 4,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // The actual ink color
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50), // Space before the loader
                    // 4. THE LOADER
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI HELPER METHODS ---

  Widget _buildBlurredBlob({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 100,
              spreadRadius: 50,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingLogo() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 10),
      duration: const Duration(seconds: 2),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, -value), // Subtle up/down float
          child: child,
        );
      },
      child: Image.asset('assets/images/glass-logo.png', height: 200),
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
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
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
      backgroundColor: AppColors.getBackgroundForPage(pageId),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 42),
          color: AppColors.getTextPrimaryForPage(pageId),
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
                gradient: AppGradients.splashBackgroundForPage(pageId),
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
                      color: AppColors.getTextPrimaryForPage(pageId),
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
                      color: AppColors.getTextPrimaryForPage(pageId),
                      fontFamily: 'ADLaMDisplay',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      color: AppColors.getTextPrimaryForPage(pageId),
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                          color: AppColors.getBorderForPage(pageId),
                        ),
                      ),
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: AppColors.getTextSecondaryForPage(pageId),
                      ),
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
                      color: AppColors.getTextPrimaryForPage(pageId),
                      fontFamily: 'ADLaMDisplay',
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: !_isPasswordVisible,
                    style: TextStyle(
                      color: AppColors.getTextPrimaryForPage(pageId),
                    ),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(
                        color: AppColors.getTextSecondaryForPage(pageId),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                          color: AppColors.getBorderForPage(pageId),
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.getTextSecondaryForPage(pageId),
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
                      color: AppColors.getAccentForPage(pageId),
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
                    backgroundColor: AppColors.getAccentForPage(pageId),
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
                    color: AppColors.getTextPrimaryForPage(pageId),
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
                      color: AppColors.getTextPrimaryForPage(pageId),
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
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
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
      backgroundColor: AppColors.getBackgroundForPage(pageId),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 42),
          color: AppColors.getTextPrimaryForPage(pageId),
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
                gradient: AppGradients.splashBackgroundForPage(pageId),
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
                      color: AppColors.getTextPrimaryForPage(pageId),
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
                      color: AppColors.getTextPrimaryForPage(pageId),
                      fontFamily: 'ADLaMDisplay',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    style: TextStyle(
                      color: AppColors.getTextPrimaryForPage(pageId),
                    ),
                    decoration: InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(
                        color: AppColors.getTextSecondaryForPage(pageId),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                          color: AppColors.getBorderForPage(pageId),
                        ),
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
                      color: AppColors.getTextPrimaryForPage(pageId),
                      fontFamily: 'ADLaMDisplay',
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      color: AppColors.getTextPrimaryForPage(pageId),
                    ),
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(
                        color: AppColors.getTextSecondaryForPage(pageId),
                      ),
                      helperText: "Use a valid, permanent email address",
                      helperStyle: TextStyle(
                        color: AppColors.getTextSecondaryForPage(pageId),
                        fontSize: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                          color: AppColors.getBorderForPage(pageId),
                        ),
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
                      color: AppColors.getTextPrimaryForPage(pageId),
                      fontFamily: 'ADLaMDisplay',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: passwordController,
                    obscureText: !_isPasswordVisible,
                    maxLength: 11,
                    style: TextStyle(
                      color: AppColors.getTextPrimaryForPage(pageId),
                    ),
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(
                        color: AppColors.getTextSecondaryForPage(pageId),
                      ),
                      helperText: "6-11 chars, 1 capital, 1 number",
                      helperStyle: TextStyle(
                        color: AppColors.getTextSecondaryForPage(pageId),
                        fontSize: 12,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                          color: AppColors.getBorderForPage(pageId),
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.getTextSecondaryForPage(pageId),
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
                      color: AppColors.getTextPrimaryForPage(pageId),
                      fontFamily: 'ADLaMDisplay',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    maxLength: 11,
                    style: TextStyle(
                      color: AppColors.getTextPrimaryForPage(pageId),
                    ),
                    decoration: InputDecoration(
                      hintText: "Re-enter your password",
                      hintStyle: TextStyle(
                        color: AppColors.getTextSecondaryForPage(pageId),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                          color: AppColors.getBorderForPage(pageId),
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: AppColors.getTextSecondaryForPage(pageId),
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
                    backgroundColor: AppColors.getAccentForPage(pageId),
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
                    color: AppColors.getTextPrimaryForPage(pageId),
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
                      color: AppColors.getTextPrimaryForPage(pageId),
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
