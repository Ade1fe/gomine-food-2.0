import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:gomine_food/widgets/app_scaffold.dart';
import '../../../consants/image_constants.dart';
import '../../../theme/theme.dart';
// import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/main_container_screen.dart';
import '../signin/sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _acceptTerms = false;
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
    _fullNameController.dispose();
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
                    SizedBox(height: size.height * 0.03),
                    _buildLogo(),
                    SizedBox(height: size.height * 0.04),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildWelcomeText(),
                    ),
                    SizedBox(height: size.height * 0.03),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildSocialSignUpButtons(),
                    ),
                    SizedBox(height: size.height * 0.02),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildDivider(),
                    ),
                    SizedBox(height: size.height * 0.02),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildNameField(),
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildEmailField(),
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildPasswordField(),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildTermsCheckbox(),
                    ),
                    SizedBox(height: size.height * 0.03),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildSignUpButton(),
                    ),
                    SizedBox(height: size.height * 0.02),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildSignInOption(),
                    ),
                    SizedBox(height: size.height * 0.03),
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
                width: 70,
                height: 70,
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
              'Create your culinary journey',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign up to discover delicious meals delivered to your door',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade300
                : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialSignUpButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          icon: 'assets/icons/google.png',
          onPressed: () {
            // Implement Google sign-up
          },
        ),
        const SizedBox(width: 20),
        _buildSocialButton(
          icon: 'assets/icons/facebook.png',
          onPressed: () {
            // Implement Facebook sign-up
          },
        ),
        const SizedBox(width: 20),
        _buildSocialButton(
          icon: 'assets/icons/apple.png',
          onPressed: () {
            // Implement Apple sign-up
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
            'Or sign up with email',
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

  Widget _buildNameField() {
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
        controller: _fullNameController,
        hintText: 'Enter your full name',
        labelText: 'Full Name',
        keyboardType: TextInputType.name,
        prefixIcon: Icon(
          Icons.person_outline,
          color: Colors.deepOrange.shade400,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your full name';
          }
          return null;
        },
      ),
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
        hintText: 'Create a password',
        labelText: 'Password',
        obscureText: true,
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Colors.deepOrange.shade400,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a password';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters long';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
            activeColor: Colors.deepOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'By creating an account, you agree to our ',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade300
                    : Colors.grey.shade700,
              ),
              children: [
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange.shade400,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Navigate to Terms of Service
                    },
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange.shade400,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Navigate to Privacy Policy
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading || !_acceptTerms ? null : _signUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          shadowColor: Colors.deepOrange.withValues(alpha:0.3),
          disabledBackgroundColor: Colors.grey.shade400,
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
                'Create Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildSignInOption() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: 'Already have an account? ',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade300
                : Colors.grey.shade700,
          ),
          children: [
            TextSpan(
              text: 'Sign In',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange.shade400,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) => const SignInScreen()),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }

  void _signUp() {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Please accept the Terms of Service and Privacy Policy'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        // Navigate to home screen
        // ignore: use_build_context_synchronously
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const MainContainerScreen()),
        );
      });
    }
  }
}
