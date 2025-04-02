
import 'package:flutter/material.dart';

class BottomNavigation extends StatefulWidget {
  final int initialIndex;
  final Function(int) onTabChanged;

  const BottomNavigation({
    super.key,
    this.initialIndex = 0,
    required this.onTabChanged,
  });

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late AnimationController _animationController;
  final List<GlobalKey> _navKeys = List.generate(4, (index) => GlobalKey());

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
      _animationController.reset();
      _animationController.forward();
    });

    widget.onTabChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Increased height to accommodate content
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        // Set maintainBottomViewPadding to true to handle bottom insets properly
        maintainBottomViewPadding: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, 'Home', Icons.home_rounded),
              _buildNavItem(1, 'User', Icons.person_rounded),
              _buildNavItem(2, 'Download', Icons.download_rounded),
              _buildNavItem(3, 'Message', Icons.chat_bubble_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      key: _navKeys[index],
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 6), // Reduced vertical padding
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: isSelected
                      ? Offset(0, _animationController.value * -4)
                      : Offset.zero,
                  child: child,
                );
              },
              child: Icon(
                icon,
                color:
                    isSelected ? Theme.of(context).primaryColor : Colors.grey,
                size: isSelected ? 26 : 22, // Slightly reduced icon size
              ),
            ),
            const SizedBox(height: 2), // Reduced spacing
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 11 : 10, // Slightly reduced font size
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color:
                    isSelected ? Theme.of(context).primaryColor : Colors.grey,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// For a more advanced version with badges for cart and messages
class BottomNavigationWithBadges extends StatefulWidget {
  final int initialIndex;
  final Function(int) onTabChanged;
  final int downloadItemCount;
  final int unreadMessageCount;

  const BottomNavigationWithBadges({
    super.key,
    this.initialIndex = 0,
    required this.onTabChanged,
    this.downloadItemCount = 0,
    this.unreadMessageCount = 0,
  });

  @override
  State<BottomNavigationWithBadges> createState() =>
      _BottomNavigationWithBadgesState();
}

class _BottomNavigationWithBadgesState extends State<BottomNavigationWithBadges>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late AnimationController _animationController;
  final List<GlobalKey> _navKeys = List.generate(4, (index) => GlobalKey());

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
      _animationController.reset();
      _animationController.forward();
    });

    widget.onTabChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Increased height to accommodate content with badges
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        maintainBottomViewPadding: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, 'Home', Icons.home_rounded),
              _buildNavItem(1, 'Search', Icons.search_rounded),
              _buildNavItemWithBadge(2, 'Explore', Icons.download_done_rounded,
                  widget.downloadItemCount),
              // _buildNavItemWithBadge(
              //     3, 'Profile', Icons.person, widget.unreadMessageCount),
              _buildNavItem(3, 'Profile', Icons.person),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      key: _navKeys[index],
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 6), // Reduced vertical padding
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: isSelected
                      ? Offset(0, _animationController.value * -4)
                      : Offset.zero,
                  child: child,
                );
              },
              child: Icon(
                icon,
                color:
                    isSelected ? Theme.of(context).primaryColor : Colors.grey,
                size: isSelected ? 26 : 22, // Slightly reduced icon size
              ),
            ),
            const SizedBox(height: 2), // Reduced spacing
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 11 : 10, // Slightly reduced font size
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color:
                    isSelected ? Theme.of(context).primaryColor : Colors.grey,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItemWithBadge(
      int index, String label, IconData icon, int count) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      key: _navKeys[index],
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 6), // Reduced vertical padding
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: isSelected
                          ? Offset(0, _animationController.value * -4)
                          : Offset.zero,
                      child: child,
                    );
                  },
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    size: isSelected ? 26 : 22, // Slightly reduced icon size
                  ),
                ),
                if (count > 0)
                  Positioned(
                    right: -6, // Adjusted position
                    top: -6, // Adjusted position
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3), // Reduced padding
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16, // Reduced size
                          minHeight: 16, // Reduced size
                        ),
                        child: Center(
                          child: Text(
                            count > 99 ? '99+' : count.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9, // Reduced font size
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2), // Reduced spacing
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 11 : 10, // Slightly reduced font size
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color:
                    isSelected ? Theme.of(context).primaryColor : Colors.grey,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
