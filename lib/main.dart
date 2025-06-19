
import 'package:flutter/material.dart';
import 'package:gomine_food/screens/auth/signin/sign_in_screen.dart';
import 'package:gomine_food/widgets/app_scaffold.dart';
import 'consants/image_constants.dart';
import 'theme/theme.dart';
import 'widgets/custom_button.dart';
// Import the main container screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gomine Food',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.darkTheme(context),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const FindYourScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      padding: EdgeInsets.zero,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              ImageConstants.logo,
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
            Text(
              'Gomine_Food',
              style: AppTextStyles.getStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextPrimary
                    : AppColors.brown,
              ),
            ),
            Text(
              'Delivery of Favorite Food',
              style: AppTextStyles.body.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w500,
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
}

class FindYourScreen extends StatelessWidget {
  const FindYourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              ImageConstants.foodimg,
              width: 300,
              height: 300,
            ),
            const SizedBox(height: 20),
            Text(
              'Find your comfort here',
              style: AppTextStyles.subHeading.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Here you can order and find your preferred food to taste.',
              style: AppTextStyles.body.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20,
            ),
            CustomButton(
              text: 'Next',
              width: 150,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
              type: ButtonType.primary,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}