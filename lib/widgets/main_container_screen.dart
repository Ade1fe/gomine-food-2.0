import 'package:flutter/material.dart';
import 'package:gomine_food/screens/profile/profile_screen.dart';
import 'package:gomine_food/widgets/recipe_library_screen.dart';
import '../screens/dashboard/home_screen.dart';
import '../screens/search/search_screen.dart';
import '../widgets/bottom_navigation.dart';
import '../services/download_service.dart';

class MainContainerScreen extends StatefulWidget {
  const MainContainerScreen({super.key});

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final DownloadService _downloadService = DownloadService();
  int _downloadCount = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const RecipeLibraryScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeDownloadCount();

    // Listen for changes to the download count
    _downloadService.downloadCount.addListener(_updateDownloadCount);
  }

  Future<void> _initializeDownloadCount() async {
    await _downloadService.initialize();
    _updateDownloadCount();
  }

  void _updateDownloadCount() {
    setState(() {
      _downloadCount = _downloadService.getDownloadCount();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _downloadService.downloadCount.removeListener(_updateDownloadCount);
    super.dispose();
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationWithBadges(
        initialIndex: _currentIndex,
        onTabChanged: _onTabChanged,
        downloadItemCount: _downloadCount,
        // unreadMessageCount: 5,
      ),
    );
  }
}
