import 'package:flutter/material.dart';
import 'package:gomine_food/widgets/app_scaffold.dart';
import '../../../consants/image_constants.dart';
import '../../../theme/theme.dart';
// import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../signup/sign_up_screen.dart';
import 'package:flutter/gestures.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _rememberMe = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppScaffold(
      showAppBar: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [Colors.grey.shade900, Colors.black]
                : [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: size.height * 0.05),
                    _buildLogo(),
                    SizedBox(height: size.height * 0.05),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildWelcomeText(),
                    ),
                    SizedBox(height: size.height * 0.04),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildSocialLoginButtons(),
                    ),
                    SizedBox(height: size.height * 0.03),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildDivider(),
                    ),
                    SizedBox(height: size.height * 0.03),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildEmailField(),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildPasswordField(),
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildRememberForgot(),
                    ),
                    SizedBox(height: size.height * 0.04),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildSignInButton(),
                    ),
                    SizedBox(height: size.height * 0.03),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildSignUpOption(),
                    ),
                    SizedBox(height: size.height * 0.05),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Hero(
      tag: 'app_logo',
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha:0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Image.asset(
                ImageConstants.logo,
                width: 80,
                height: 80,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Gomine Food',
              style: AppTextStyles.getStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.brown,
              ),
            ),
            Text(
              'Delicious food at your doorstep',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Welcome Back!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to continue your culinary journey',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade300
                  : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          icon: 'assets/icons/google.png',
          onPressed: () {
            // Implement Google sign-in
          },
        ),
        const SizedBox(width: 20),
        _buildSocialButton(
          icon: 'assets/icons/facebook.png',
          onPressed: () {
            // Implement Facebook sign-in
          },
        ),
        const SizedBox(width: 20),
        _buildSocialButton(
          icon: 'assets/icons/apple.png',
          onPressed: () {
            // Implement Apple sign-in
          },
        ),
      ],
    );
  }

  Widget _buildSocialButton(
      {required String icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey.shade800
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          // Use a placeholder icon since we don't have the actual assets
          child: Icon(
            icon.contains('google')
                ? Icons.g_mobiledata
                : icon.contains('facebook')
                    ? Icons.facebook
                    : Icons.apple,
            size: 30,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade300,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or sign in with',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade300,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.03),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CustomTextField(
        controller: _emailController,
        hintText: 'Enter your email',
        labelText: 'Email',
        keyboardType: TextInputType.emailAddress,
        prefixIcon: Icon(
          Icons.email_outlined,
          color: Colors.deepOrange.shade400,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.03),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CustomTextField(
        controller: _passwordController,
        hintText: 'Enter your password',
        labelText: 'Password',
        obscureText: true,
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Colors.deepOrange.shade400,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters long';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Remember me',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade300
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () {
            // Implement forgot password
          },
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.deepOrange.shade400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          shadowColor: Colors.deepOrange.withValues(alpha:0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildSignUpOption() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: 'Don\'t have an account? ',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade300
                : Colors.grey.shade700,
          ),
          children: [
            TextSpan(
              text: 'Sign Up',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange.shade400,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const SignUpScreen()),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }

  void _signIn() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        // Navigate to home screen or show error
        // For now, just navigate to sign up screen as in the original code
        // ignore: use_build_context_synchronously
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SignUpScreen()),
        );
      });
    }
  }
}
