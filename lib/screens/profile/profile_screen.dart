import 'package:flutter/material.dart';
import 'package:gomine_food/widgets/app_scaffold.dart';
// Import additional packages
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
// import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // User data
  String userName = 'John Doe';
  String userEmail = 'johndoe@example.com';
  String userBio = 'Food lover and cooking enthusiast';
  String profileImage = 'assets/images/profile_placeholder.png';
  
  // Settings
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  String selectedLanguage = 'English';
  bool locationEnabled = true;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = userName;
    _emailController.text = userEmail;
    _bioController.text = userBio;
    
    // Load user settings
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      selectedLanguage = prefs.getString('selected_language') ?? 'English';
      locationEnabled = prefs.getBool('location_enabled') ?? true;
    });
  }

  Future<void> _saveUserSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', notificationsEnabled);
    await prefs.setBool('dark_mode_enabled', darkModeEnabled);
    await prefs.setString('selected_language', selectedLanguage);
    await prefs.setBool('location_enabled', locationEnabled);
    
    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      padding: EdgeInsets.zero,
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepOrange, Colors.orangeAccent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showImageSourceOptions,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundImage: AssetImage(profileImage),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.deepOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildProfileCard(
              title: "Account",
              options: [
                _ProfileOption(
                  icon: Icons.edit,
                  label: "Edit Profile",
                  onTap: _showEditProfileModal,
                ),
                _ProfileOption(
                  icon: Icons.lock,
                  label: "Change Password",
                  onTap: _showChangePasswordModal,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProfileCard(
              title: "Settings",
              options: [
                _ProfileOption(
                  icon: Icons.settings,
                  label: "App Settings",
                  onTap: _showAppSettingsModal,
                ),
                _ProfileOption(
                  icon: Icons.help_outline,
                  label: "Help & Support",
                  onTap: () => _navigateToHelpSupport(context),
                ),
                _ProfileOption(
                  icon: Icons.logout,
                  label: "Logout",
                  iconColor: Colors.red,
                  onTap: _handleLogout,
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required String title,
    required List<_ProfileOption> options,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ),
            ...options.map((option) => ListTile(
                  leading: Icon(option.icon, color: option.iconColor),
                  title: Text(option.label),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: option.onTap,
                )),
          ],
        ),
      ),
    );
  }

  // Modal for Edit Profile
  void _showEditProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Modal for Change Password
  void _showChangePasswordModal() {
    // Reset password controllers
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  helperText: 'Password must be at least 8 characters',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_clock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _updatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Update Password'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  // Modal for App Settings
  void _showAppSettingsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'App Settings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Notifications
                  ListTile(
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive alerts about orders and promotions'),
                    trailing: Switch(
                      value: notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          notificationsEnabled = value;
                        });
                      },
                      activeColor: Colors.deepOrange,
                    ),
                  ),
                  
                  // Dark Mode
                  ListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Use dark theme for the app'),
                    trailing: Switch(
                      value: darkModeEnabled,
                      onChanged: (value) {
                        setState(() {
                          darkModeEnabled = value;
                        });
                      },
                      activeColor: Colors.deepOrange,
                    ),
                  ),
                  
                  // Location Services
                  ListTile(
                    title: const Text('Location Services'),
                    subtitle: const Text('Allow app to access your location'),
                    trailing: Switch(
                      value: locationEnabled,
                      onChanged: (value) {
                        setState(() {
                          locationEnabled = value;
                        });
                      },
                      activeColor: Colors.deepOrange,
                    ),
                  ),
                  
                  // Language Selection
                  ListTile(
                    title: const Text('Language'),
                    subtitle: Text(selectedLanguage),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _showLanguageSelectionDialog(setState);
                    },
                  ),
                  
                  const Divider(),
                  
                  // App Version
                  const ListTile(
                    title: Text('App Version'),
                    subtitle: Text('1.0.0'),
                    trailing: Icon(Icons.info_outline),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _saveUserSettings();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save Settings'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Navigate to Help & Support screen (full page instead of modal)
  void _navigateToHelpSupport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HelpSupportScreen(),
      ),
    );
  }

  // Profile update methods
  void _updateProfile() {
    // Validate inputs
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name and email cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
    _showLoadingDialog();

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      // Update state
      setState(() {
        userName = _nameController.text;
        userEmail = _emailController.text;
        userBio = _bioController.text;
      });

      // Close loading dialog
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      
      // Close modal
      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      // Show success message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _updatePassword() {
    // Validate inputs
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All fields are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 8 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
    _showLoadingDialog();

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      // Close loading dialog
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      
      // Close modal
      // ignore: use_build_context_synchronously
      Navigator.pop(context);

      // Show success message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  // Image picker methods
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      // In a real app, you would upload this image to your server
      // and update the profile image URL
      
      // For this example, we'll just show a success message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Language selection dialog
  void _showLanguageSelectionDialog(StateSetter updateState) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('English', updateState),
              _buildLanguageOption('Spanish', updateState),
              _buildLanguageOption('French', updateState),
              _buildLanguageOption('German', updateState),
              _buildLanguageOption('Chinese', updateState),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption(String language, StateSetter updateState) {
    return ListTile(
      title: Text(language),
      trailing: selectedLanguage == language
          ? const Icon(Icons.check, color: Colors.deepOrange)
          : null,
      onTap: () {
        updateState(() {
          selectedLanguage = language;
        });
        Navigator.pop(context);
      },
    );
  }

  // Logout handling
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                
                // Show loading indicator
                _showLoadingDialog();
                
                // Perform logout operations
                try {
                  await _performLogout();
                  
                  // Navigate to login screen and clear navigation stack
                  Navigator.pushNamedAndRemoveUntil(
                    // ignore: use_build_context_synchronously
                    context, 
                    '/login', 
                    (route) => false,
                  );
                } catch (e) {
                  // Hide loading dialog
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  
                  // Show error message
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logout failed: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Helper methods
  Future<void> _performLogout() async {
    // Simulate network request
    await Future.delayed(const Duration(seconds: 1));
    
    // Clear user session data
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // You would also clear any auth tokens, user data, etc.
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
            ),
          ),
        );
      },
    );
  }
}

// Help & Support Screen (Full Page)
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contact Support Section
              const Text(
                'Contact Support',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildContactCard(
                context: context,
                title: 'Email Support',
                subtitle: 'support@gominefood.com',
                icon: Icons.email,
                onTap: () {
                  // In a real app, implement email functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening email client...')),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildContactCard(
                context: context,
                title: 'Call Support',
                subtitle: '+1 (555) 123-4567',
                icon: Icons.phone,
                onTap: () {
                  // In a real app, implement phone call functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calling support...')),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildContactCard(
                context: context,
                title: 'Live Chat',
                subtitle: 'Available 24/7',
                icon: Icons.chat_bubble,
                onTap: () {
                  // In a real app, open chat interface
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening live chat...')),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // FAQs Section
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildFAQItem(
                question: 'How do I place an order?',
                answer: 'Browse restaurants, select items, add to cart, and checkout. You can pay online or choose cash on delivery.',
              ),
              _buildFAQItem(
                question: 'How can I track my order?',
                answer: 'Go to Orders tab to see real-time updates on your delivery. You\'ll also receive notifications about your order status.',
              ),
              _buildFAQItem(
                question: 'What payment methods are accepted?',
                answer: 'We accept credit/debit cards, PayPal, and cash on delivery. All online payments are secure and encrypted.',
              ),
              _buildFAQItem(
                question: 'How do I add a new address?',
                answer: 'Go to Profile > Addresses > Add New Address. You can save multiple addresses for different locations.',
              ),
              _buildFAQItem(
                question: 'Can I cancel my order?',
                answer: 'You can cancel within 5 minutes of placing the order. After that, please contact support for assistance.',
              ),
              
              const SizedBox(height: 24),
              
              // Report a Problem Section
              const Text(
                'Report a Problem',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Having issues with the app? Let us know!',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showReportProblemDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Report a Problem'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Terms & Privacy Section
              const Text(
                'Terms & Privacy Policy',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Terms of Service',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'By using our app, you agree to these terms. We reserve the right to change these terms at any time.',
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'We collect personal information to provide and improve our services. We do not sell your data to third parties.',
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Data Usage',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'We use cookies and similar technologies to enhance your experience, analyze usage, and assist in our marketing efforts.',
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            // In a real app, navigate to full terms and privacy policy
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening full terms and privacy policy...')),
                            );
                          },
                          child: const Text('Read Full Policy'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // App Version
              const Center(
                child: Text(
                  'App Version 1.0.0',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.deepOrange,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer),
          ),
        ],
      ),
    );
  }

  void _showReportProblemDialog(BuildContext context) {
    String selectedIssue = 'App Crashes';
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Report a Problem'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Issue Type:'),
                    DropdownButton<String>(
                      value: selectedIssue,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedIssue = newValue;
                          });
                        }
                      },
                      items: <String>[
                        'App Crashes',
                        'Payment Issues',
                        'Order Problems',
                        'Account Issues',
                        'Other',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text('Description:'),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Please describe the issue in detail',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      onChanged: (value) {
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Problem report submitted. We\'ll look into it!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ProfileOption {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor; // Make iconColor nullable to handle optional cases

  const _ProfileOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });
}