// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// import 'app_scaffold.dart' show AppScaffold;

// // Custom search field widget
// class CustomSearchField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hintText;
//   final Function(String) onChanged;
//   final VoidCallback onClear;
//   final Color backgroundColor;

//   const CustomSearchField({
//     super.key,
//     required this.controller,
//     required this.hintText,
//     required this.onChanged,
//     required this.onClear,
//     this.backgroundColor = Colors.white,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 50,
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(25),
//       ),
//       child: TextField(
//         controller: controller,
//         onChanged: onChanged,
//         decoration: InputDecoration(
//           hintText: hintText,
//           prefixIcon: const Icon(Icons.search, color: Colors.grey),
//           suffixIcon: controller.text.isNotEmpty
//               ? IconButton(
//                   icon: const Icon(Icons.clear, color: Colors.grey),
//                   onPressed: onClear,
//                 )
//               : null,
//           border: InputBorder.none,
//           contentPadding:
//               const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//         ),
//       ),
//     );
//   }
// }

// class CategoryDetailScreen extends StatefulWidget {
//   final dynamic category;
//   final String cookingTime;

//   const CategoryDetailScreen({
//     super.key,
//     required this.category,
//     required this.cookingTime,
//   });

//   @override
//   State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
// }

// class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
//   List<dynamic> meals = [];
//   bool isLoading = true;
//   String errorMessage = '';
//   bool isDescriptionExpanded = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchMealsByCategory();
//   }

//   Future<void> fetchMealsByCategory() async {
//     try {
//       final response = await http.get(
//         Uri.parse(
//             'https://www.themealdb.com/api/json/v1/1/filter.php?c=${widget.category.strCategory}'),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           meals = data['meals'] ?? [];
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           errorMessage = 'Failed to load meals: ${response.statusCode}';
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Error: $e';
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           _buildAppBar(context),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 16),
//                   _buildInfoRow(),
//                   const SizedBox(height: 24),
//                   _buildDescriptionSection(),
//                   const SizedBox(height: 24),
//                   _buildPopularDishesSection(context),
//                   const SizedBox(height: 24),
//                   _buildExploreButton(context),
//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppBar(BuildContext context) {
//     return SliverAppBar(
//       expandedHeight: 280,
//       pinned: true,
//       backgroundColor: Colors.white,
//       foregroundColor: Colors.black,
//       // backgroundColor: Theme.of(context).primaryColor,
//       elevation: 0,
//       leading: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: CircleAvatar(
//           backgroundColor: Colors.black26,
//           child: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ),
//       ),
//       actions: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: CircleAvatar(
//             backgroundColor: Colors.black26,
//             child: IconButton(
//               icon: const Icon(Icons.favorite_border, color: Colors.white),
//               onPressed: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Added to favorites')),
//                 );
//               },
//             ),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: CircleAvatar(
//             backgroundColor: Colors.black26,
//             child: IconButton(
//               icon: const Icon(Icons.share, color: Colors.white),
//               onPressed: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                       content: Text('Share functionality coming soon')),
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//       flexibleSpace: FlexibleSpaceBar(
//         title: Text(
//           widget.category.strCategory,
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//             shadows: [
//               Shadow(
//                 blurRadius: 10.0,
//                 color: Colors.black54,
//                 offset: Offset(0, 0),
//               ),
//             ],
//           ),
//         ),
//         background: Stack(
//           fit: StackFit.expand,
//           children: [
//             Image.network(
//               widget.category.strCategoryThumb,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   color: Colors.grey[300],
//                   child: const Icon(Icons.broken_image,
//                       color: Colors.red, size: 40),
//                 );
//               },
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return Container(
//                   color: Colors.grey[300],
//                   child: Center(
//                     child: CircularProgressIndicator(
//                       value: loadingProgress.expectedTotalBytes != null
//                           ? loadingProgress.cumulativeBytesLoaded /
//                               loadingProgress.expectedTotalBytes!
//                           : null,
//                     ),
//                   ),
//                 );
//               },
//             ),
//             // Gradient overlay for better text visibility
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.transparent,
//                     Colors.black.withValues(alpha:0.7),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow() {
//     return Row(
//       children: [
//         // Cooking time badge
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(
//             color: Colors.orange.withValues(alpha:0.2),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.access_time, size: 16, color: Colors.orange),
//               const SizedBox(width: 4),
//               Text(
//                 widget.cookingTime,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.orange,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 12),
//         // Rating badge
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(
//             color: Colors.green.withValues(alpha:0.2),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: const [
//               Icon(Icons.star, size: 16, color: Colors.green),
//               SizedBox(width: 4),
//               Text(
//                 '4.8',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.green,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(width: 12),
//         // Difficulty badge
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//           decoration: BoxDecoration(
//             color: Colors.blue.withValues(alpha:0.2),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: const [
//               Icon(Icons.trending_up, size: 16, color: Colors.blue),
//               SizedBox(width: 4),
//               Text(
//                 'Medium',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.blue,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDescriptionSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             const Text(
//               'Descriptionsss',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const Spacer(),
//             TextButton(
//               onPressed: () {
//                 setState(() {
//                   isDescriptionExpanded = !isDescriptionExpanded;
//                 });
//               },
//               child: Text(isDescriptionExpanded ? 'Show Less' : 'Read More'),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         AnimatedCrossFade(
//           firstChild: Text(
//             _truncateDescription(widget.category.strCategoryDescription),
//             style: const TextStyle(
//               fontSize: 16,
//               height: 1.5,
//               color: Colors.black87,
//             ),
//           ),
//           secondChild: Text(
//             widget.category.strCategoryDescription,
//             style: const TextStyle(
//               fontSize: 16,
//               height: 1.5,
//               color: Colors.black87,
//             ),
//           ),
//           crossFadeState: isDescriptionExpanded
//               ? CrossFadeState.showSecond
//               : CrossFadeState.showFirst,
//           duration: const Duration(milliseconds: 300),
//         ),
//       ],
//     );
//   }

//   String _truncateDescription(String description) {
//     if (description.length > 200) {
//       return '${description.substring(0, 200)}...';
//     }
//     return description;
//   }

//   Widget _buildPopularDishesSection(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Popular ${widget.category.strCategory} Dishes',
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => AllMealsScreen(
//                       category: widget.category,
//                       meals: meals,
//                     ),
//                   ),
//                 );
//               },
//               child: const Text('View All'),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         if (isLoading)
//           _buildLoadingGrid()
//         else if (errorMessage.isNotEmpty)
//           _buildErrorMessage()
//         else if (meals.isEmpty)
//           _buildEmptyState()
//         else
//           GridView.builder(
//             physics: const NeverScrollableScrollPhysics(),
//             shrinkWrap: true,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 0.8,
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 16,
//             ),
//             itemCount: meals.length > 6 ? 6 : meals.length, // Limit to 6 items
//             itemBuilder: (context, index) {
//               final meal = meals[index];
//               return _buildMealCard(meal, context);
//             },
//           ),
//       ],
//     );
//   }

//   Widget _buildLoadingGrid() {
//     return GridView.builder(
//       physics: const NeverScrollableScrollPhysics(),
//       shrinkWrap: true,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 0.8,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//       ),
//       itemCount: 6,
//       itemBuilder: (context, index) {
//         return Container(
//           decoration: BoxDecoration(
//             color: Colors.grey[300],
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: const Center(
//             child: CircularProgressIndicator(),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildErrorMessage() {
//     return Center(
//       child: Column(
//         children: [
//           const Icon(Icons.error_outline, size: 48, color: Colors.red),
//           const SizedBox(height: 16),
//           Text(
//             errorMessage,
//             style: const TextStyle(fontSize: 16),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () {
//               setState(() {
//                 isLoading = true;
//                 errorMessage = '';
//               });
//               fetchMealsByCategory();
//             },
//             child: const Text('Try Again'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         children: [
//           const Icon(Icons.restaurant, size: 48, color: Colors.grey),
//           const SizedBox(height: 16),
//           Text(
//             'No ${widget.category.strCategory} dishes found',
//             style: const TextStyle(fontSize: 16),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMealCard(dynamic meal, BuildContext context) {
//     // Generate random cooking time between 15-45 minutes
//     final cookingTime = '${15 + (meal['idMeal'].hashCode % 30)} min';
//     final imageUrl = meal['strMealThumb'];

//     return GestureDetector(
//       onTap: () {
//         // Navigate to meal detail screen (not implemented)
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Selected: ${meal['strMeal']}')),
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha:0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Meal image
//               Expanded(
//                 child: Stack(
//                   children: [
//                     Image.network(
//                       imageUrl,
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                       height: double.infinity,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Container(
//                           color: Colors.grey[300],
//                           child:
//                               const Icon(Icons.restaurant, color: Colors.grey),
//                         );
//                       },
//                       loadingBuilder: (context, child, loadingProgress) {
//                         if (loadingProgress == null) return child;
//                         return Container(
//                           color: Colors.grey[300],
//                           child: Center(
//                             child: CircularProgressIndicator(
//                               value: loadingProgress.expectedTotalBytes != null
//                                   ? loadingProgress.cumulativeBytesLoaded /
//                                       loadingProgress.expectedTotalBytes!
//                                   : null,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     // Rating badge
//                     Positioned(
//                       top: 8,
//                       right: 8,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(Icons.star,
//                                 color: Colors.amber, size: 16),
//                             const SizedBox(width: 2),
//                             Text(
//                               (4.0 + (meal['idMeal'].hashCode % 10) / 10)
//                                   .toStringAsFixed(1),
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Meal info
//               Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       meal['strMeal'],
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         const Icon(Icons.access_time,
//                             size: 14, color: Colors.grey),
//                         const SizedBox(width: 4),
//                         Text(
//                           cookingTime,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildExploreButton(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: () {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Explore recipes feature coming soon!'),
//             ),
//           );
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Theme.of(context).primaryColor,
//           foregroundColor: Colors.white,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           elevation: 2,
//         ),
//         child: Text(
//           'Explore All ${widget.category.strCategory} Recipes',
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // New screen for "View All" functionality
// class AllMealsScreen extends StatefulWidget {
//   final dynamic category;
//   final List<dynamic> meals;

//   const AllMealsScreen({
//     super.key,
//     required this.category,
//     required this.meals,
//   });

//   @override
//   State<AllMealsScreen> createState() => _AllMealsScreenState();
// }

// class _AllMealsScreenState extends State<AllMealsScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   List<dynamic> filteredMeals = [];

//   @override
//   void initState() {
//     super.initState();
//     filteredMeals = List.from(widget.meals);
//   }

//   void _filterMeals(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         filteredMeals = List.from(widget.meals);
//       } else {
//         filteredMeals = widget.meals
//             .where((meal) => meal['strMeal']
//                 .toString()
//                 .toLowerCase()
//                 .contains(query.toLowerCase()))
//             .toList();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AppScaffold(
//       appBar: AppBar(
//         title: Text(
//           'All ${widget.category.strCategory} Dishes',
//           style: TextStyle(
//               fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: CustomSearchField(
//               controller: _searchController,
//               hintText: 'Search for food...',
//               onChanged: (query) {
//                 _filterMeals(query);
//               },
//               onClear: () {
//                 _searchController.clear();
//                 _filterMeals('');
//               },
//               backgroundColor: const Color.fromARGB(235, 100, 82, 73),
//             ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(5.0),
//               child: filteredMeals.isEmpty
//                   ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(Icons.search_off,
//                               size: 64, color: Colors.grey),
//                           const SizedBox(height: 16),
//                           Text(
//                             'No ${widget.category.strCategory} dishes found matching your search',
//                             style: const TextStyle(fontSize: 18),
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//                     )
//                   : GridView.builder(
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         childAspectRatio: 0.8,
//                         crossAxisSpacing: 16,
//                         mainAxisSpacing: 16,
//                       ),
//                       itemCount: filteredMeals.length,
//                       itemBuilder: (context, index) {
//                         final meal = filteredMeals[index];
//                         return _buildMealCard(meal, context);
//                       },
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMealCard(dynamic meal, BuildContext context) {
//     // Generate random cooking time between 15-45 minutes
//     final cookingTime = '${15 + (meal['idMeal'].hashCode % 30)} min';
//     final imageUrl = meal['strMealThumb'];

//     return GestureDetector(
//       onTap: () {
//         // Navigate to meal detail screen (not implemented)
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Selected: ${meal['strMeal']}')),
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha:0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Meal image
//               Expanded(
//                 child: Stack(
//                   children: [
//                     Image.network(
//                       imageUrl,
//                       fit: BoxFit.cover,
//                       width: double.infinity,
//                       height: double.infinity,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Container(
//                           color: Colors.grey[300],
//                           child:
//                               const Icon(Icons.restaurant, color: Colors.grey),
//                         );
//                       },
//                       loadingBuilder: (context, child, loadingProgress) {
//                         if (loadingProgress == null) return child;
//                         return Container(
//                           color: Colors.grey[300],
//                           child: Center(
//                             child: CircularProgressIndicator(
//                               value: loadingProgress.expectedTotalBytes != null
//                                   ? loadingProgress.cumulativeBytesLoaded /
//                                       loadingProgress.expectedTotalBytes!
//                                   : null,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     // Rating badge
//                     Positioned(
//                       top: 8,
//                       right: 8,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             const Icon(Icons.star,
//                                 color: Colors.amber, size: 16),
//                             const SizedBox(width: 2),
//                             Text(
//                               (4.0 + (meal['idMeal'].hashCode % 10) / 10)
//                                   .toStringAsFixed(1),
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 12,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Meal info
//               Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       meal['strMeal'],
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         const Icon(Icons.access_time,
//                             size: 14, color: Colors.grey),
//                         const SizedBox(width: 4),
//                         Text(
//                           cookingTime,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'app_scaffold.dart' show AppScaffold;
import 'recipe_detail_screen.dart' show RecipeDetailScreen;

// Custom search field widget
class CustomSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String) onChanged;
  final VoidCallback onClear;
  final Color backgroundColor;

  const CustomSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.deepOrange),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}

class CategoryDetailScreen extends StatefulWidget {
  final dynamic category;
  final String cookingTime;

  const CategoryDetailScreen({
    super.key,
    required this.category,
    required this.cookingTime,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  List<dynamic> meals = [];
  bool isLoading = true;
  String errorMessage = '';
  bool isDescriptionExpanded = false;
  final Color primaryColor = Colors.deepOrange;

  @override
  void initState() {
    super.initState();
    fetchMealsByCategory();
  }

  Future<void> fetchMealsByCategory() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://www.themealdb.com/api/json/v1/1/filter.php?c=${widget.category.strCategory}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          meals = data['meals'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load meals: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildInfoRow(),
                  const SizedBox(height: 24),
                  _buildDescriptionSection(),
                  const SizedBox(height: 24),
                  _buildPopularDishesSection(context),
                  const SizedBox(height: 24),
                  _buildExploreButton(context),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black26,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black26,
            child: IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Added to favorites'),
                    backgroundColor: primaryColor,
                  ),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black26,
            child: IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Share functionality coming soon'),
                    backgroundColor: primaryColor,
                  ),
                );
              },
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.category.strCategory,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black54,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.category.strCategoryThumb,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image,
                      color: Colors.red, size: 40),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: primaryColor,
                    ),
                  ),
                );
              },
            ),
            // Gradient overlay for better text visibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha:0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        // Cooking time badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.access_time, size: 16, color: primaryColor),
              const SizedBox(width: 4),
              Text(
                widget.cookingTime,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Rating badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: primaryColor.withValues(alpha:0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                '4.8',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Difficulty badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: primaryColor.withValues(alpha:0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.trending_up, size: 16, color: primaryColor),
              const SizedBox(width: 4),
              Text(
                'Medium',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    isDescriptionExpanded = !isDescriptionExpanded;
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                ),
                child: Text(isDescriptionExpanded ? 'Show Less' : 'Read More'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedCrossFade(
            firstChild: Text(
              _truncateDescription(widget.category.strCategoryDescription),
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            secondChild: Text(
              widget.category.strCategoryDescription,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
            crossFadeState: isDescriptionExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  String _truncateDescription(String description) {
    if (description.length > 200) {
      return '${description.substring(0, 200)}...';
    }
    return description;
  }

  Widget _buildPopularDishesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular ${widget.category.strCategory} Dishes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllMealsScreen(
                        category: widget.category,
                        meals: meals,
                        primaryColor: primaryColor,
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                ),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            _buildLoadingGrid()
          else if (errorMessage.isNotEmpty)
            _buildErrorMessage()
          else if (meals.isEmpty)
            _buildEmptyState()
          else
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount:
                  meals.length > 6 ? 6 : meals.length, // Limit to 6 items
              itemBuilder: (context, index) {
                final meal = meals[index];
                return _buildMealCard(meal, context);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = '';
              });
              fetchMealsByCategory();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.restaurant,
              size: 48, color: primaryColor.withValues(alpha:0.5)),
          const SizedBox(height: 16),
          Text(
            'No ${widget.category.strCategory} dishes found',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(dynamic meal, BuildContext context) {
    // Generate random cooking time between 15-45 minutes
    final cookingTime = '${15 + (meal['idMeal'].hashCode % 30)} min';
    final imageUrl = meal['strMealThumb'];

    return GestureDetector(
      onTap: () {
        // Navigate to meal detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(
              mealId: meal['idMeal'],
              mealName: meal['strMeal'],
              mealImage: meal['strMealThumb'],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal image
              Expanded(
                child: Stack(
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child:
                              const Icon(Icons.restaurant, color: Colors.grey),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: primaryColor,
                            ),
                          ),
                        );
                      },
                    ),
                    // Rating badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha:0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 2),
                            Text(
                              (4.0 + (meal['idMeal'].hashCode % 10) / 10)
                                  .toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Cooking time badge
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha:0.7),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                cookingTime,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Meal info
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  meal['strMeal'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExploreButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllMealsScreen(
                category: widget.category,
                meals: meals,
                primaryColor: primaryColor,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: primaryColor.withValues(alpha:0.4),
        ),
        child: Text(
          'Explore All ${widget.category.strCategory} Recipes',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// New screen for "View All" functionality
class AllMealsScreen extends StatefulWidget {
  final dynamic category;
  final List<dynamic> meals;
  final Color primaryColor;

  const AllMealsScreen({
    super.key,
    required this.category,
    required this.meals,
    required this.primaryColor,
  });

  @override
  State<AllMealsScreen> createState() => _AllMealsScreenState();
}

class _AllMealsScreenState extends State<AllMealsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredMeals = [];

  @override
  void initState() {
    super.initState();
    filteredMeals = List.from(widget.meals);
  }

  void _filterMeals(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredMeals = List.from(widget.meals);
      } else {
        filteredMeals = widget.meals
            .where((meal) => meal['strMeal']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'All ${widget.category.strCategory} Dishes',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CustomSearchField(
              controller: _searchController,
              hintText: 'Search for food...',
              onChanged: (query) {
                _filterMeals(query);
              },
              onClear: () {
                _searchController.clear();
                _filterMeals('');
              },
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: filteredMeals.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 64,
                              color: widget.primaryColor.withValues(alpha:0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No ${widget.category.strCategory} dishes found matching your search',
                            style: const TextStyle(fontSize: 18),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              _searchController.clear();
                              _filterMeals('');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Clear Search'),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredMeals.length,
                      itemBuilder: (context, index) {
                        final meal = filteredMeals[index];
                        return _buildMealCard(meal, context);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(dynamic meal, BuildContext context) {
    // Generate random cooking time between 15-45 minutes
    final cookingTime = '${15 + (meal['idMeal'].hashCode % 30)} min';
    final imageUrl = meal['strMealThumb'];

    return GestureDetector(
      onTap: () {
        // Navigate to meal detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(
              mealId: meal['idMeal'],
              mealName: meal['strMeal'],
              mealImage: meal['strMealThumb'],
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meal image
              Expanded(
                child: Stack(
                  children: [
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child:
                              const Icon(Icons.restaurant, color: Colors.grey),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: widget.primaryColor,
                            ),
                          ),
                        );
                      },
                    ),
                    // Rating badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha:0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 2),
                            Text(
                              (4.0 + (meal['idMeal'].hashCode % 10) / 10)
                                  .toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Cooking time badge
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha:0.7),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                cookingTime,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Meal info
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  meal['strMeal'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
