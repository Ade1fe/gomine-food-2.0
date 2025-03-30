// import 'dart:convert';
// import 'dart:math';
// // import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// // import 'package:flutter/widgets.dart';
// import 'package:http/http.dart' as http;

// class MealCategory {
//   final String idCategory;
//   final String strCategory;
//   final String strCategoryThumb;
//   final String strCategoryDescription;

//   MealCategory({
//     required this.idCategory,
//     required this.strCategory,
//     required this.strCategoryThumb,
//     required this.strCategoryDescription,
//   });

//   factory MealCategory.fromJson(Map<String, dynamic> json) {
//     return MealCategory(
//       idCategory: json['idCategory'],
//       strCategory: json['strCategory'],
//       strCategoryThumb: json['strCategoryThumb'],
//       strCategoryDescription: json['strCategoryDescription'],
//     );
//   }
// }

// class PopularMenu extends StatefulWidget {
//   const PopularMenu({super.key});

//   @override
//   State<PopularMenu> createState() => _PopularMenuState();
// }

// class _PopularMenuState extends State<PopularMenu> {
//   List<MealCategory> _categories = [];
//   bool _isLoading = true;
//   String? _errorMessage;
//   final Random _random = Random();

//   @override
//   void initState() {
//     super.initState();
//     _fetchMealCategories();
//   }

//   Future<void> _fetchMealCategories() async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'),
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         final List<dynamic> categoriesJson = data['categories'];

//         setState(() {
//           _categories = categoriesJson
//               .map((json) => MealCategory.fromJson(json))
//               .take(5)
//               .toList();
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to load meal categories';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }

//   String _getRandomCookingTime() {
//     return '${_random.nextInt(30) + 10} mins';
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }

//     if (_errorMessage != null) {
//       return Center(
//         child: Text(
//           _errorMessage!,
//           style: const TextStyle(color: Colors.red),
//         ),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Popular Categories',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   // Navigate to all categories
//                 },
//                 child: const Text(
//                   'See All',
//                   style: TextStyle(
//                     color: Colors.orange,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         ..._categories.map((category) => _buildCategoryItem(category)),
//       ],
//     );
//   }

//   Widget _buildCategoryItem(MealCategory category) {
//     return GestureDetector(
//       onTap: () {
//         print('Selected category: ${category.strCategory}');
//       },
//       child: Container(
//         margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: Stack(
//             children: [
//               // Image with gradient overlay
//               ShaderMask(
//                 shaderCallback: (rect) {
//                   return LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.transparent,
//                       Colors.black.withOpacity(0.7),
//                     ],
//                   ).createShader(rect);
//                 },
//                 blendMode: BlendMode.darken,
//                 child: Image.network(
//                   category.strCategoryThumb,
//                   width: MediaQuery.of(context).size.width,
//                   height: 180,
//                   fit: BoxFit.cover,
//                   loadingBuilder: (context, child, loadingProgress) {
//                     if (loadingProgress == null) return child;
//                     return Container(
//                       height: 180,
//                       color: Colors.grey[300],
//                       child: const Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                     );
//                   },
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       height: 180,
//                       color: Colors.grey[300],
//                       child: const Center(
//                         child: Icon(Icons.error),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               // Info container
//               Positioned(
//                 bottom: 16,
//                 left: 16,
//                 right: 16,
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     color: Colors.white.withOpacity(0.9),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               category.strCategory,
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               category.strCategoryDescription,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.black54,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.orange.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           _getRandomCookingTime(),
//                           style: const TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.orange,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'all_categories_screen.dart';
// import 'category_detail_screen.dart';

// class MealCategory {
//   final String idCategory;
//   final String strCategory;
//   final String strCategoryThumb;
//   final String strCategoryDescription;

//   MealCategory({
//     required this.idCategory,
//     required this.strCategory,
//     required this.strCategoryThumb,
//     required this.strCategoryDescription,
//   });

//   factory MealCategory.fromJson(Map<String, dynamic> json) {
//     return MealCategory(
//       idCategory: json['idCategory'],
//       strCategory: json['strCategory'],
//       strCategoryThumb: json['strCategoryThumb'],
//       strCategoryDescription: json['strCategoryDescription'],
//     );
//   }
// }

// class PopularMenu extends StatefulWidget {
//   const PopularMenu({super.key});

//   @override
//   State<PopularMenu> createState() => _PopularMenuState();
// }

// class _PopularMenuState extends State<PopularMenu> {
//   List<MealCategory> _allCategories = [];
//   List<MealCategory> _displayedCategories = [];
//   bool _isLoading = true;
//   String? _errorMessage;
//   final Random _random = Random();

//   @override
//   void initState() {
//     super.initState();
//     _fetchMealCategories();
//   }

//   Future<void> _fetchMealCategories() async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'),
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         final List<dynamic> categoriesJson = data['categories'];

//         setState(() {
//           _allCategories = categoriesJson
//               .map((json) => MealCategory.fromJson(json))
//               .toList();

//           // Only display first 5 categories initially
//           _displayedCategories = _allCategories.take(5).toList();
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to load meal categories';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }

//   String _getRandomCookingTime() {
//     return '${_random.nextInt(30) + 10} mins';
//   }

//   void _navigateToAllCategories() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AllCategoriesScreen(categories: _allCategories),
//       ),
//     );
//   }

//   void _navigateToCategoryDetail(MealCategory category) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => CategoryDetailScreen(
//           category: category,
//           cookingTime: _getRandomCookingTime(),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }

//     if (_errorMessage != null) {
//       return Center(
//         child: Text(
//           _errorMessage!,
//           style: const TextStyle(color: Colors.red),
//         ),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Popular Categories',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               TextButton(
//                 onPressed: _navigateToAllCategories,
//                 child: const Text(
//                   'See All',
//                   style: TextStyle(
//                     color: Colors.orange,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         ..._displayedCategories.map((category) => _buildCategoryItem(category)).toList(),
//       ],
//     );
//   }

//   Widget _buildCategoryItem(MealCategory category) {
//     return GestureDetector(
//       onTap: () => _navigateToCategoryDetail(category),
//       child: Container(
//         margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: Stack(
//             children: [
//               // Image with gradient overlay
//               ShaderMask(
//                 shaderCallback: (rect) {
//                   return LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.transparent,
//                       Colors.black.withOpacity(0.7),
//                     ],
//                   ).createShader(rect);
//                 },
//                 blendMode: BlendMode.darken,
//                 child: Image.network(
//                   category.strCategoryThumb,
//                   width: MediaQuery.of(context).size.width,
//                   height: 180,
//                   fit: BoxFit.cover,
//                   loadingBuilder: (context, child, loadingProgress) {
//                     if (loadingProgress == null) return child;
//                     return Container(
//                       height: 180,
//                       color: Colors.grey[300],
//                       child: const Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                     );
//                   },
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       height: 180,
//                       color: Colors.grey[300],
//                       child: const Center(
//                         child: Icon(Icons.error),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               // Info container
//               Positioned(
//                 bottom: 16,
//                 left: 16,
//                 right: 16,
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     color: Colors.white.withOpacity(0.9),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               category.strCategory,
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               category.strCategoryDescription,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.black54,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.orange.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           _getRandomCookingTime(),
//                           style: const TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.orange,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'dart:convert';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'category_detail_screen.dart';

// class MealCategory {
//   final String idCategory;
//   final String strCategory;
//   final String strCategoryThumb;
//   final String strCategoryDescription;

//   MealCategory({
//     required this.idCategory,
//     required this.strCategory,
//     required this.strCategoryThumb,
//     required this.strCategoryDescription,
//   });

//   factory MealCategory.fromJson(Map<String, dynamic> json) {
//     return MealCategory(
//       idCategory: json['idCategory'],
//       strCategory: json['strCategory'],
//       strCategoryThumb: json['strCategoryThumb'],
//       strCategoryDescription: json['strCategoryDescription'],
//     );
//   }
// }

// class PopularMenu extends StatefulWidget {
//   const PopularMenu({super.key});

//   @override
//   State<PopularMenu> createState() => _PopularMenuState();
// }

// class _PopularMenuState extends State<PopularMenu> {
//   List<MealCategory> _allCategories = [];
//   bool _isLoading = true;
//   String? _errorMessage;
//   final Random _random = Random();
//   bool _showAllCategories = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchMealCategories();
//   }

//   Future<void> _fetchMealCategories() async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'),
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         final List<dynamic> categoriesJson = data['categories'];

//         setState(() {
//           _allCategories = categoriesJson
//               .map((json) => MealCategory.fromJson(json))
//               .toList();
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _errorMessage = 'Failed to load meal categories';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error: ${e.toString()}';
//         _isLoading = false;
//       });
//     }
//   }

//   String _getRandomCookingTime() {
//     return '${_random.nextInt(30) + 10} mins';
//   }

//   void _toggleShowAllCategories() {
//     setState(() {
//       _showAllCategories = !_showAllCategories;
//     });
//   }

//   void _navigateToCategoryDetail(MealCategory category) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => CategoryDetailScreen(
//           category: category,
//           cookingTime: _getRandomCookingTime(),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }

//     if (_errorMessage != null) {
//       return Center(
//         child: Text(
//           _errorMessage!,
//           style: const TextStyle(color: Colors.red),
//         ),
//       );
//     }

//     // Determine which categories to display
//     final displayedCategories =
//         _showAllCategories ? _allCategories : _allCategories.take(5).toList();

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Popular Categories',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               TextButton(
//                 onPressed: _toggleShowAllCategories,
//                 child: Text(
//                   _showAllCategories ? 'Show Less' : 'See All',
//                   style: const TextStyle(
//                     color: Colors.orange,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         ...displayedCategories
//             .map((category) => _buildCategoryItem(category))
//             .toList(),
//       ],
//     );
//   }

//   Widget _buildCategoryItem(MealCategory category) {
//     return GestureDetector(
//       onTap: () => _navigateToCategoryDetail(category),
//       child: Container(
//         margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 8,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: Stack(
//             children: [
//               // Image with gradient overlay
//               ShaderMask(
//                 shaderCallback: (rect) {
//                   return LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.transparent,
//                       Colors.black.withOpacity(0.7),
//                     ],
//                   ).createShader(rect);
//                 },
//                 blendMode: BlendMode.darken,
//                 child: Image.network(
//                   category.strCategoryThumb,
//                   width: MediaQuery.of(context).size.width,
//                   height: 180,
//                   fit: BoxFit.cover,
//                   loadingBuilder: (context, child, loadingProgress) {
//                     if (loadingProgress == null) return child;
//                     return Container(
//                       height: 180,
//                       color: Colors.grey[300],
//                       child: const Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                     );
//                   },
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       height: 180,
//                       color: Colors.grey[300],
//                       child: const Center(
//                         child: Icon(Icons.error),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               // Info container
//               Positioned(
//                 bottom: 16,
//                 left: 16,
//                 right: 16,
//                 child: Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     color: Colors.white.withOpacity(0.9),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               category.strCategory,
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               category.strCategoryDescription,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.black54,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.orange.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           _getRandomCookingTime(),
//                           style: const TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.orange,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
