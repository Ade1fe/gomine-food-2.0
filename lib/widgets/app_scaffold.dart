// import 'package:flutter/material.dart';
// import '../theme/theme.dart';

// class AppScaffold extends StatelessWidget {
//   final Widget? title;
//   final Widget body;
//   final Widget? floatingActionButton;
//   final List<Widget>? actions;
//   final Widget? leading;
//   final Color? backgroundColor;
//   final Color? appBarColor;
//   final Widget? bottomNavigationBar;
//   final bool showAppBar;
//   final EdgeInsetsGeometry padding;
//   final PreferredSizeWidget? appBar;
//   final double? appBarElevation;
//   final bool centerTitle;

//   const AppScaffold({
//     super.key,
//     this.title,
//     required this.body,
//     this.floatingActionButton,
//     this.actions,
//     this.leading,
//     this.backgroundColor,
//     this.appBarColor,
//     this.bottomNavigationBar,
//     this.showAppBar = true,
//     this.padding = const EdgeInsets.all(16.0),
//     this.appBar,
//     this.appBarElevation,
//     this.centerTitle = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDarkMode = theme.brightness == Brightness.dark;

//     return Scaffold(
//       appBar: showAppBar
//           ? appBar ??
//               AppBar(
//                 title: title,
//                 backgroundColor: appBarColor ??
//                     (isDarkMode ? AppColors.primary : AppColors.secondary),
//                 elevation: appBarElevation ?? 0,
//                 leading: leading ??
//                     (Navigator.of(context).canPop()
//                         ? IconButton(
//                             icon: Icon(
//                               Icons.arrow_back,
//                               color: isDarkMode
//                                   ? AppColors.textPrimary
//                                   : AppColors.textSecondary,
//                             ),
//                             onPressed: () => Navigator.of(context).pop(),
//                           )
//                         : null),
//                 actions: actions,
//                 centerTitle: centerTitle,
//               )
//           : null,
//       body: Padding(
//         padding: padding,
//         child: body,
//       ),
//       floatingActionButton: floatingActionButton,
//       backgroundColor:
//           backgroundColor ?? (isDarkMode ? AppColors.background : Colors.white),
//       bottomNavigationBar: bottomNavigationBar,
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class AppScaffold extends StatelessWidget {
  final Widget? title;
  final Widget body;
  final Widget? floatingActionButton;
  final List<Widget>? actions;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? appBarColor;
  final Widget? bottomNavigationBar;
  final bool showAppBar;
  final EdgeInsetsGeometry padding;
  final PreferredSizeWidget? appBar;
  final double? appBarElevation;
  final bool centerTitle;

  const AppScaffold({
    super.key,
    this.title,
    required this.body,
    this.floatingActionButton,
    this.actions,
    this.leading,
    this.backgroundColor,
    this.appBarColor,
    this.bottomNavigationBar,
    this.showAppBar = true,
    this.padding = const EdgeInsets.all(16.0),
    this.appBar,
    this.appBarElevation,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: showAppBar
          ? appBar ??
              AppBar(
                title: title,
                backgroundColor: appBarColor ??
                    (isDarkMode ? AppColors.primary : AppColors.secondary),
                elevation: appBarElevation ?? 0,
                leading: leading ??
                    (Navigator.of(context).canPop()
                        ? IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: isDarkMode
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        : null),
                actions: actions,
                centerTitle: centerTitle,
              )
          : null,
      body: Padding(
        padding: padding,
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      backgroundColor:
          backgroundColor ?? (isDarkMode ? AppColors.background : Colors.white),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
