


// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:shimmer/shimmer.dart';

// import '../../widgets/app_scaffold.dart';
// import '../../widgets/recipe_detail_screen.dart' show RecipeDetailScreen;

// // Category class for CategoryDetailScreen
// class Category {
//   final String idCategory;
//   final String strCategory;
//   final String strCategoryDescription;
//   final String strCategoryThumb;

//   Category({
//     required this.idCategory,
//     required this.strCategory,
//     required this.strCategoryDescription,
//     required this.strCategoryThumb,
//   });
// }

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _searchController = TextEditingController();
//   final FocusNode _searchFocusNode = FocusNode();
  
//   // App theme colors
//   final Color primaryColor = const Color(0xFF2C3E50);
//   final Color accentColor = const Color(0xFFFF8C00); // Changed to orange
//   final Color backgroundColor = const Color(0xFFF5F7FA);
//   final Color cardColor = Colors.white;
//   final Color textColor = const Color(0xFF2C3E50);
//   final Color secondaryTextColor = const Color(0xFF7F8C8D);

//   // In-memory storage for recent searches
//   List<String> _recentSearches = [];
//   final List<String> _popularSearches = [
//     'Pasta',
//     'Chicken',
//     'Vegetarian',
//     'Dessert',
//     'Quick Meals',
//     'Breakfast',
//     'Italian',
//     'Mexican',
//     'Healthy',
//     'Soup',
//     'Salad',
//     'Baking'
//   ];

//   List<dynamic> _searchResults = [];
//   bool _isLoading = false;
//   String _errorMessage = '';
//   bool _showClearButton = false;

//   // For filtering
//   String _selectedCategory = 'All';
//   List<String> _categories = [
//     'All',
//     'Breakfast',
//     'Lunch',
//     'Dinner',
//     'Dessert',
//     'Appetizer',
//     'Snack'
//   ];

//   // For favorites
//   final Map<String, bool> _favoriteMeals = {};

//   // For tabs
//   late TabController _tabController;

//   // For categories and trending recipes
//   List<dynamic> _mealCategories = [];
//   List<dynamic> _trendingRecipes = [];
//   bool _isLoadingCategories = true;
//   bool _isLoadingTrending = true;
//   String _categoriesError = '';
//   String _trendingError = '';

//   // For expanded category
//   String? _expandedCategoryId;
//   List<dynamic> _categoryMeals = [];
//   bool _isLoadingCategoryMeals = false;
//   String _categoryMealsError = '';
  
//   // For top snackbar
//   OverlayEntry? _overlayEntry;
//   bool _isSnackbarVisible = false;
//   Timer? _snackbarTimer;

//   @override
//   void initState() {
//     super.initState();
//     _checkFavorites();
//     _tabController = TabController(length: 3, vsync: this);

//     _searchController.addListener(() {
//       setState(() {
//         _showClearButton = _searchController.text.isNotEmpty;
//       });
//     });

//     // Fetch categories and trending recipes when screen loads
//     _fetchCategories();
//     _fetchTrendingRecipes();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _searchFocusNode.dispose();
//     _tabController.dispose();
//     _removeTopSnackBar();
//     _snackbarTimer?.cancel();
//     super.dispose();
//   }

//   // Fetch meal categories from MealDB API
//   Future<void> _fetchCategories() async {
//     setState(() {
//       _isLoadingCategories = true;
//       _categoriesError = '';
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           _mealCategories = data['categories'] ?? [];
//           _isLoadingCategories = false;
//         });
//       } else {
//         setState(() {
//           _categoriesError =
//               'Failed to load categories: ${response.statusCode}';
//           _isLoadingCategories = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _categoriesError = 'Error: $e';
//         _isLoadingCategories = false;
//       });
//     }
//   }

//   // Fetch meals by category from MealDB API
//   Future<void> _fetchMealsByCategory(String categoryName) async {
//     setState(() {
//       _isLoadingCategoryMeals = true;
//       _categoryMealsError = '';
//     });

//     try {
//       final response = await http.get(
//         Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=$categoryName'),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           _categoryMeals = data['meals'] ?? [];
//           _isLoadingCategoryMeals = false;
//         });
//       } else {
//         setState(() {
//           _categoryMealsError =
//               'Failed to load meals: ${response.statusCode}';
//           _isLoadingCategoryMeals = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _categoryMealsError = 'Error: $e';
//         _isLoadingCategoryMeals = false;
//       });
//     }
//   }

//   // Toggle category expansion
//   void _toggleCategoryExpansion(String categoryId, String categoryName) {
//     // Instead of expanding in place, show a modal
//     _showCategoryModal(categoryId, categoryName);
//   }

//   // Show category modal
//   void _showCategoryModal(String categoryId, String categoryName) {
//     // Find the selected category
//     final selectedCategory = _mealCategories.firstWhere(
//       (category) => category['idCategory'] == categoryId,
//       orElse: () => null,
//     );
    
//     if (selectedCategory == null) return;
    
//     final categoryColor = _getCategoryColor(
//       int.parse(selectedCategory['idCategory']) % 10
//     );
    
//     // Start loading the meals
//     setState(() {
//       _expandedCategoryId = categoryId;
//       _isLoadingCategoryMeals = true;
//       _categoryMeals = [];
//       _categoryMealsError = '';
//     });
    
//     // Fetch meals for this category
//     _fetchMealsByCategory(categoryName).then((_) {
//       if (!mounted) return;
      
//       // Show the modal with the fetched meals
//       showModalBottomSheet(
//   context: context,
//   backgroundColor: Colors.transparent,
//   isScrollControlled: true,
//   builder: (context) => DraggableScrollableSheet(
//     initialChildSize: 0.7,
//     minChildSize: 0.5,
//     maxChildSize: 0.95,
//     builder: (_, controller) => Container(
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Handle indicator
//           Center(
//             child: Container(
//               width: 40,
//               height: 5,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               margin: const EdgeInsets.symmetric(vertical: 8),
//             ),
//           ),
//           // Header with category name and close button
//           Padding(
//             padding: const EdgeInsets.only(
//                 left: 16, right: 16, top: 8, bottom: 16),
//             child: Row(
//               children: [
//                 Container(
//                   width: 4,
//                   height: 20,
//                   decoration: BoxDecoration(
//                     color: accentColor, // Changed to orange accent
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   '${selectedCategory['strCategory']} Recipes',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: textColor,
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => Navigator.of(context).pop(),
//                   color: secondaryTextColor,
//                 ),
//               ],
//             ),
//           ),
          
//           // Category description
//           if (selectedCategory['strCategoryDescription'] != null)
//             Padding(
//               padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
//               child: Text(
//                 selectedCategory['strCategoryDescription'],
//                 style: TextStyle(
//                   color: secondaryTextColor,
//                   fontSize: 14,
//                 ),
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
          
//           // Loading indicator
//           if (_isLoadingCategoryMeals)
//             Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: CircularProgressIndicator(
//                   color: accentColor, // Changed to orange accent
//                 ),
//               ),
//             )
//           // Error message
//           else if (_categoryMealsError.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: _buildErrorState(
//                 _categoryMealsError,
//                 'Failed to load recipes',
//                 () {
//                   Navigator.of(context).pop();
//                   _toggleCategoryExpansion(categoryId, categoryName);
//                 },
//               ),
//             )
//           // No meals found
//           else if (_categoryMeals.isEmpty)
//             Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.no_meals_rounded,
//                       size: 48,
//                       color: secondaryTextColor,
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       'No recipes found for this category',
//                       style: TextStyle(
//                         color: secondaryTextColor,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           // Meals grid
//           else
//             Expanded(
//               child: GridView.builder(
//                 controller: controller,
//                 padding: const EdgeInsets.all(16),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   childAspectRatio: 0.75,
//                   crossAxisSpacing: 12,
//                   mainAxisSpacing: 12,
//                 ),
//                 itemCount: _categoryMeals.length,
//                 itemBuilder: (context, index) {
//                   final meal = _categoryMeals[index];
//                   return _buildMealCard(meal, accentColor); // Changed to orange accent
//                 },
//               ),
//             ),
//         ],
//       ),
//     ),
//   ),
// ).then((_) {
//   // Reset the expanded category when modal is closed
//   if (mounted) {
//     setState(() {
//       _expandedCategoryId = null;
//     });
//   }
// });
//     });
//   }

//   // Fetch trending recipes from MealDB API
//   Future<void> _fetchTrendingRecipes() async {
//     setState(() {
//       _isLoadingTrending = true;
//       _trendingError = '';
//     });

//     try {
//       // We'll fetch 5 random meals to simulate trending recipes
//       List<dynamic> trendingMeals = [];

//       for (int i = 0; i < 5; i++) {
//         final response = await http.get(
//           Uri.parse('https://www.themealdb.com/api/json/v1/1/random.php'),
//         );

//         if (response.statusCode == 200) {
//           final data = json.decode(response.body);
//           if (data['meals'] != null && data['meals'].isNotEmpty) {
//             trendingMeals.add(data['meals'][0]);
//           }
//         }
//       }

//       setState(() {
//         _trendingRecipes = trendingMeals;
//         _isLoadingTrending = false;
//       });
//     } catch (e) {
//       setState(() {
//         _trendingError = 'Error: $e';
//         _isLoadingTrending = false;
//       });
//     }
//   }

//   // Save a search term to recent searches
//   void _saveSearch(String searchTerm) {
//     if (searchTerm.trim().isEmpty) return;

//     setState(() {
//       // Remove if already exists (to move it to the top)
//       _recentSearches.remove(searchTerm);

//       // Add to the beginning
//       _recentSearches.insert(0, searchTerm);

//       // Limit to 10 recent searches
//       if (_recentSearches.length > 10) {
//         _recentSearches = _recentSearches.sublist(0, 10);
//       }
//     });
//   }

//   // Clear all recent searches
//   void _clearRecentSearches() {
//     setState(() {
//       _recentSearches = [];
//     });
//   }

//   // Check which meals are already in favorites
//   Future<void> _checkFavorites() async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final favoritesFile = File('${directory.path}/favorite_recipes.json');

//       if (await favoritesFile.exists()) {
//         final content = await favoritesFile.readAsString();
//         final List<dynamic> favorites = json.decode(content);

//         setState(() {
//           for (var favorite in favorites) {
//             if (favorite['id'] != null) {
//               _favoriteMeals[favorite['id']] = true;
//             }
//           }
//         });
//       }
//     } catch (e) {
//       debugPrint('Error checking favorites: $e');
//     }
//   }

//   // Toggle favorite status
//   void _toggleFavorite(dynamic meal) {
//     final mealId = meal['idMeal'];
//     final isFavorite = _favoriteMeals[mealId] ?? false;

//     // Update the state immediately before the async operations
//     setState(() {
//       _favoriteMeals[mealId] = !isFavorite;
//     });

//     // Then handle the database operations
//     if (isFavorite) {
//       _removeFromFavorites(mealId);
//     } else {
//       _addMealToFavorites(meal);
//     }
//   }

//   // Add meal to favorites
//   Future<void> _addMealToFavorites(dynamic meal) async {
//   try {
//     // Generate a unique filename for the recipe
//     final String fileName = 'recipe_${meal['idMeal']}.pdf';

//     // Get the application documents directory
//     final directory = await getApplicationDocumentsDirectory();

//     // Create recipe metadata
//     final Map<String, dynamic> recipeMetadata = {
//       'id': meal['idMeal'],
//       'name': meal['strMeal'],
//       'fileName': fileName,
//       'imageUrl': meal['strMealThumb'],
//       'date': DateTime.now().toIso8601String(),
//       'category': meal['strCategory'] ?? 'Main Course',
//       'cuisine': meal['strArea'] ?? 'International',
//     };

//     // Load existing favorites metadata
//     final favoritesFile = File('${directory.path}/favorite_recipes.json');
//     List<Map<String, dynamic>> existingFavorites = [];

//     if (await favoritesFile.exists()) {
//       final content = await favoritesFile.readAsString();
//       final List<dynamic> decoded = json.decode(content);
//       existingFavorites = List<Map<String, dynamic>>.from(decoded);
//     }

//     // Check if recipe already exists in favorites
//     bool recipeExists =
//         existingFavorites.any((favorite) => favorite['id'] == meal['idMeal']);

//     if (recipeExists) {
//       // ignore: use_build_context_synchronously
//       _showTopSnackBar('Recipe is already in your favorites', SnackBarType.warning);
//       return;
//     }

//     // Add new recipe to favorites
//     existingFavorites.add(recipeMetadata);

//     // Save updated favorites metadata
//     await favoritesFile.writeAsString(json.encode(existingFavorites));

//     // Show success message
//     if (mounted) {
//       _showTopSnackBar('Added "${meal['strMeal']}" to favorites', SnackBarType.success);
//     }
//   } catch (e) {
//     debugPrint('Error adding meal to favorites: $e');
//     if (mounted) {
//       _showTopSnackBar('Failed to add to favorites', SnackBarType.error);
//     }
//   }
// }

//   // Remove recipe from favorites
//   Future<void> _removeFromFavorites(String mealId) async {
//   try {
//     final directory = await getApplicationDocumentsDirectory();
//     final favoritesFile = File('${directory.path}/favorite_recipes.json');

//     if (await favoritesFile.exists()) {
//       final content = await favoritesFile.readAsString();
//       List<Map<String, dynamic>> favorites =
//           List<Map<String, dynamic>>.from(json.decode(content));
      
//       // Find the recipe name before removing it
//       String recipeName = "Recipe";
//       final recipeToRemove = favorites.firstWhere(
//         (favorite) => favorite['id'] == mealId,
//         orElse: () => {"name": "Recipe"},
//       );
      
//       if (recipeToRemove.containsKey("name")) {
//         recipeName = recipeToRemove["name"];
//       }

//       // Remove this recipe from favorites
//       favorites.removeWhere((favorite) => favorite['id'] == mealId);

//       // Save updated favorites
//       await favoritesFile.writeAsString(json.encode(favorites));

//       // Show success message
//       if (mounted) {
//         _showTopSnackBar('Removed "$recipeName" from favorites', SnackBarType.info);
//       }
//     }
//   } catch (e) {
//     if (mounted) {
//       _showTopSnackBar('Error removing from favorites', SnackBarType.error);
//     }
//   }
// }

//   // Remove any existing top snackbar
//   void _removeTopSnackBar() {
//     _overlayEntry?.remove();
//     _overlayEntry = null;
//     _isSnackbarVisible = false;
//     _snackbarTimer?.cancel();
//   }

//   // Show custom top snackbar
//   void _showTopSnackBar(String message, SnackBarType type) {
//     // If there's already a snackbar showing, remove it first
//     if (_isSnackbarVisible) {
//       _removeTopSnackBar();
//     }

//     Color backgroundColor;
//     Color textColor = Colors.white;
//     IconData icon;
    
//     // Determine colors and icon based on snackbar type
//     switch (type) {
//       case SnackBarType.success:
//         backgroundColor = const Color(0xFF2ECC71);
//         icon = Icons.check_circle_rounded;
//         break;
//       case SnackBarType.error:
//         backgroundColor = const Color(0xFFE74C3C);
//         icon = Icons.error_rounded;
//         break;
//       case SnackBarType.warning:
//         backgroundColor = const Color(0xFFF39C12);
//         icon = Icons.warning_rounded;
//         break;
//       case SnackBarType.info:
//         backgroundColor = accentColor;
//         icon = Icons.info_rounded;
//         break;
//     }

//     // Create the overlay entry
//     _overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         top: MediaQuery.of(context).viewPadding.top + 10,
//         left: 10,
//         right: 10,
//         child: Material(
//           color: Colors.transparent,
//           child: TweenAnimationBuilder<double>(
//             tween: Tween<double>(begin: 0.0, end: 1.0),
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeOut,
//             builder: (context, value, child) {
//               return Transform.translate(
//                 offset: Offset(0, -50 * (1 - value)),
//                 child: Opacity(
//                   opacity: value,
//                   child: child,
//                 ),
//               );
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 color: backgroundColor,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 10,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   Icon(icon, color: textColor, size: 24),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       message,
//                       style: TextStyle(
//                         color: textColor,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.close, color: textColor.withOpacity(0.8), size: 20),
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(),
//                     onPressed: _removeTopSnackBar,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );

//     // Show the overlay
//     Overlay.of(context).insert(_overlayEntry!);
//     _isSnackbarVisible = true;

//     // Auto-dismiss after 3 seconds
//     _snackbarTimer = Timer(const Duration(seconds: 3), () {
//       _removeTopSnackBar();
//     });
//   }

//   // Open favorites bottom sheet
//   void _openFavoritesBottomSheet() async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final favoritesFile = File('${directory.path}/favorite_recipes.json');

//       List<Map<String, dynamic>> favoriteRecipes = [];
//       if (await favoritesFile.exists()) {
//         final content = await favoritesFile.readAsString();
//         favoriteRecipes = List<Map<String, dynamic>>.from(json.decode(content));
//       }

//       if (favoriteRecipes.isEmpty) {
//         _showTopSnackBar('No favorite recipes yet', SnackBarType.info);
//         return;
//       }

//       // Sort by date (newest first)
//       favoriteRecipes.sort((a, b) =>
//           DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

//       if (mounted) {
//         showModalBottomSheet(
//   context: context,
//   backgroundColor: Colors.transparent,
//   isScrollControlled: true,
//   builder: (context) => DraggableScrollableSheet(
//     initialChildSize: 0.7,
//     minChildSize: 0.5,
//     maxChildSize: 0.95,
//     builder: (_, controller) => Container(
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Handle indicator
//           Center(
//             child: Container(
//               width: 40,
//               height: 5,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               margin: const EdgeInsets.symmetric(vertical: 8),
//             ),
//           ),
//           // Header
//           Padding(
//             padding: const EdgeInsets.only(
//                 left: 16, right: 16, top: 8, bottom: 16),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Your Favorite Recipes',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: textColor,
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.close),
//                   onPressed: () => Navigator.of(context).pop(),
//                   color: secondaryTextColor,
//                 ),
//               ],
//             ),
//           ),
//           // Favorited recipes list
//           Expanded(
//             child: ListView.builder(
//               controller: controller,
//               itemCount: favoriteRecipes.length,
//               itemBuilder: (context, index) {
//                 final recipe = favoriteRecipes[index];
//                 final date = DateTime.parse(recipe['date']);
//                 final now = DateTime.now();

//                 String formattedDate;
//                 if (now.difference(date).inDays == 0) {
//                   formattedDate = 'Today';
//                 } else if (now.difference(date).inDays == 1) {
//                   formattedDate = 'Yesterday';
//                 } else {
//                   formattedDate =
//                       '${date.day}/${date.month}/${date.year}';
//                 }

//                 return _buildFavoriteCard(recipe, formattedDate);
//               },
//             ),
//           ),
//         ],
//       ),
//     ),
//   ),
// );
//       }
//     } catch (e) {
//       _showTopSnackBar('Error loading favorites', SnackBarType.error);
//     }
//   }

//   // Build a card for favorite recipes
//   Widget _buildFavoriteCard(Map<String, dynamic> recipe, String date) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () {
//           Navigator.of(context).pop();
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => RecipeDetailScreen(
//                 mealId: recipe['id'],
//                 mealName: recipe['name'],
//                 mealImage: recipe['imageUrl'],
//               ),
//             ),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               // Recipe image
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: CachedNetworkImage(
//                   imageUrl: recipe['imageUrl'],
//                   width: 80,
//                   height: 80,
//                   fit: BoxFit.cover,
//                   placeholder: (context, url) => Shimmer.fromColors(
//                     baseColor: Colors.grey[300]!,
//                     highlightColor: Colors.grey[100]!,
//                     child: Container(
//                       width: 80,
//                       height: 80,
//                       color: Colors.white,
//                     ),
//                   ),
//                   errorWidget: (context, url, error) => Container(
//                     width: 80,
//                     height: 80,
//                     color: Colors.grey.shade200,
//                     child: Icon(
//                       Icons.image_not_supported_rounded,
//                       size: 30,
//                       color: secondaryTextColor,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               // Recipe details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Recipe name
//                     Text(
//                       recipe['name'],
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: textColor,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     // Category and cuisine
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.category_rounded,
//                           size: 14,
//                           color: secondaryTextColor,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           recipe['category'] ?? 'Main Course',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: secondaryTextColor,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Icon(
//                           Icons.public_rounded,
//                           size: 14,
//                           color: secondaryTextColor,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           recipe['cuisine'] ?? 'International',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: secondaryTextColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     // Added date
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.access_time_rounded,
//                           size: 14,
//                           color: secondaryTextColor,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           'Added: $date',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: secondaryTextColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               // View button
//               Container(
//                 decoration: BoxDecoration(
//                   color: accentColor.withOpacity(0.1), // Changed to orange accent
//                   shape: BoxShape.circle,
//                 ),
//                 child: IconButton(
//                   icon: Icon(
//                     Icons.arrow_forward_ios_rounded,
//                     size: 16,
//                     color: accentColor, // Changed to orange accent
//                   ),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => RecipeDetailScreen(
//                           mealId: recipe['id'],
//                           mealName: recipe['name'],
//                           mealImage: recipe['imageUrl'],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Perform search
//   Future<void> _performSearch(String query) async {
//     if (query.trim().isEmpty) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });

//     try {
//       // Save to recent searches (no await needed now)
//       _saveSearch(query);

//       // API call to search for meals
//       final response = await http.get(
//         Uri.parse(
//             'https://www.themealdb.com/api/json/v1/1/search.php?s=${query.trim()}'),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           _searchResults = data['meals'] ?? [];
//           _isLoading = false;

//           // Switch to results tab if we have results
//           if (_searchResults.isNotEmpty) {
//             _tabController.animateTo(1); // Results tab
//           }
//         });
//       } else {
//         setState(() {
//           _errorMessage =
//               'Failed to load search results: ${response.statusCode}';
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Error: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   // Filter search results by category
//   List<dynamic> _getFilteredResults() {
//     if (_selectedCategory == 'All') {
//       return _searchResults;
//     }

//     return _searchResults.where((meal) {
//       final category = meal['strCategory'] ?? '';
//       return category.toLowerCase() == _selectedCategory.toLowerCase();
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final filteredResults = _getFilteredResults();

//     return AppScaffold(
//       appBar: AppBar(
//         title: Text(
//           'Culinary Explorer',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: textColor,
//           ),
//         ),
//         backgroundColor: cardColor,
//         foregroundColor: textColor,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.favorite_rounded),
//             onPressed: _openFavoritesBottomSheet,
//             color: const Color(0xFFE74C3C),
//           ),
//         ],
//       ),
//       body: Container(
//         color: backgroundColor,
//         child: Column(
//           children: [
//             // Search bar
//             Container(
//               padding: const EdgeInsets.all(16.0),
//               decoration: BoxDecoration(
//                 color: cardColor,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     spreadRadius: 0,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   ProfessionalSearchField(
//                     controller: _searchController,
                    
//                     hintText: 'Search for recipes, ingredients...',
//                     onChanged: (value) {
//                       // We'll handle search on submit
//                     },
//                     onClear: () {
//                       _searchController.clear();
//                       setState(() {
//                         _showClearButton = false;
//                       });
//                     },
//                     onSubmitted: (value) => _performSearch(value),
//                   ),
//                   const SizedBox(height: 12),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () => _performSearch(_searchController.text),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: accentColor, // Changed to orange accent
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         elevation: 0,
//                       ),
//                       child: const Text(
//                         'Search',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Tab bar
//             Container(
//               color: cardColor,
//               child: TabBar(
//                 controller: _tabController,
//                 labelColor: accentColor, // Changed to orange accent
//                 unselectedLabelColor: secondaryTextColor,
//                 indicatorColor: accentColor, // Changed to orange accent
//                 indicatorSize: TabBarIndicatorSize.label,
//                 labelStyle: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                 ),
//                 tabs: const [
//                   Tab(text: 'DISCOVER'),
//                   Tab(text: 'RESULTS'),
//                   Tab(text: 'RECENT'),
//                 ],
//               ),
//             ),

//             // Tab content
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   // Discover tab
//                   _buildDiscoverTab(),

//                   // Results tab
//                   _buildResultsTab(filteredResults),

//                   // Recent searches tab
//                   _buildRecentSearchesTab(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Discover tab content
//   Widget _buildDiscoverTab() {
//     return Container(
//       color: backgroundColor,
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Popular searches section
//             SectionHeader(
//               title: 'Popular Searches',
//               icon: Icons.trending_up_rounded,
//               color: textColor,
//             ),
//             const SizedBox(height: 12),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: _popularSearches.map((search) {
//                 return InkWell(
//                   onTap: () {
//                     _searchController.text = search;
//                     _performSearch(search);
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: cardColor,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(
//                         color: Colors.grey.shade200,
//                       ),
//                     ),
//                     child: Text(
//                       search,
//                       style: TextStyle(
//                         color: textColor,
//                         fontSize: 13,
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),

//             const SizedBox(height: 24),

//             // Categories section
//             SectionHeader(
//               title: 'Browse by Category',
//               icon: Icons.category_rounded,
//               color: textColor,
//             ),
//             const SizedBox(height: 12),

//             // Categories grid with loading state
//             _isLoadingCategories
//               ? _buildLoadingCategories()
//               : _categoriesError.isNotEmpty
//                 ? _buildErrorState(
//                     _categoriesError,
//                     'Failed to load categories',
//                     _fetchCategories,
//                   )
//                 : GridView.builder(
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       childAspectRatio: 1.2,
//                       crossAxisSpacing: 12,
//                       mainAxisSpacing: 12,
//                     ),
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: _mealCategories.length,
//                     itemBuilder: (context, index) {
//                       final category = _mealCategories[index];
//                       final isExpanded = _expandedCategoryId == category['idCategory'];
                      
//                       return _buildCategoryCard(
//                         category['strCategory'],
//                         category['strCategoryThumb'],
//                         _getCategoryColor(index),
//                         category,
//                         isExpanded,
//                       );
//                     },
//                   ),

//             const SizedBox(height: 24),

//             // Trending recipes section
//             SectionHeader(
//               title: 'Trending Recipes',
//               icon: Icons.local_fire_department_rounded,
//               color: textColor,
//             ),
//             const SizedBox(height: 12),

//             // Trending recipes with loading state
//             _isLoadingTrending
//               ? _buildLoadingTrendingRecipes()
//               : _trendingError.isNotEmpty
//                 ? _buildErrorState(
//                     _trendingError,
//                     'Failed to load trending recipes',
//                     _fetchTrendingRecipes,
//                   )
//                 : SizedBox(
//                     height: 220,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: _trendingRecipes.length,
//                       itemBuilder: (context, index) {
//                         final recipe = _trendingRecipes[index];
//                         return _buildTrendingRecipeCard(
//                           recipe['strMeal'],
//                           recipe['strCategory'] ?? 'Main Course',
//                           '${15 + (recipe['idMeal'].hashCode % 30)} min',
//                           recipe['strMealThumb'],
//                           recipe,
//                         );
//                       },
//                     ),
//                   ),

//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }

//   // Loading state for categories
//   Widget _buildLoadingCategories() {
//     return GridView.builder(
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         childAspectRatio: 1.2,
//         crossAxisSpacing: 12,
//         mainAxisSpacing: 12,
//       ),
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: 6,
//       itemBuilder: (context, index) {
//         return Shimmer.fromColors(
//           baseColor: Colors.grey[300]!,
//           highlightColor: Colors.grey[100]!,
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // Loading state for trending recipes
//   Widget _buildLoadingTrendingRecipes() {
//     return SizedBox(
//       height: 220,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: 5,
//         itemBuilder: (context, index) {
//           return Shimmer.fromColors(
//             baseColor: Colors.grey[300]!,
//             highlightColor: Colors.grey[100]!,
//             child: Container(
//               width: 160,
//               margin: const EdgeInsets.only(right: 12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // Error state widget
//   Widget _buildErrorState(String error, String message, VoidCallback onRetry) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         children: [
//           Icon(
//             Icons.error_outline_rounded,
//             color: const Color(0xFFE74C3C),
//             size: 48,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: textColor,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 8),
//           Text(
//             error,
//             style: TextStyle(
//               fontSize: 14,
//               color: secondaryTextColor,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton.icon(
//             onPressed: onRetry,
//             icon: const Icon(Icons.refresh_rounded),
//             label: const Text('Try Again'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: accentColor, // Changed to orange accent
//               foregroundColor: Colors.white,
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Get a color for a category based on its index
//   Color _getCategoryColor(int index) {
//     final colors = [
//       accentColor, // Changed to orange accent (primary)
//       const Color(0xFF2ECC71), // Green
//       const Color(0xFFE74C3C), // Red
//       const Color(0xFF9B59B6), // Purple
//       const Color(0xFFF39C12), // Orange
//       const Color(0xFF1ABC9C), // Teal
//       const Color(0xFFD35400), // Dark Orange
//       const Color(0xFF8E44AD), // Dark Purple
//       const Color(0xFF2980B9), // Dark Blue
//       const Color(0xFF27AE60), // Dark Green
//     ];

//     return colors[index % colors.length];
//   }

//   // Category card for browse by category
//   Widget _buildCategoryCard(
//       String title, String imageUrl, Color color, dynamic category, bool isExpanded) {
//     return InkWell(
//       onTap: () {
//         // Toggle category expansion instead of navigating
//         _toggleCategoryExpansion(category['idCategory'], category['strCategory']);
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             // Image background
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: CachedNetworkImage(
//                 imageUrl: imageUrl,
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) => Shimmer.fromColors(
//                   baseColor: Colors.grey[300]!,
//                   highlightColor: Colors.grey[100]!,
//                   child: Container(
//                     color: Colors.white,
//                   ),
//                 ),
//                 errorWidget: (context, url, error) => Container(
//                   color: color.withOpacity(0.1),
//                   child: Center(
//                     child: Icon(
//                       Icons.restaurant_rounded,
//                       size: 40,
//                       color: color.withOpacity(0.5),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
            
//             // Gradient overlay
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.transparent,
//                       Colors.black.withOpacity(0.7),
//                     ],
//                     stops: const [0.5, 1.0],
//                   ),
//                 ),
//               ),
//             ),
            
//             // Category name and icon
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         title,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                           shadows: [
//                             Shadow(
//                               offset: Offset(0, 1),
//                               blurRadius: 3,
//                               color: Colors.black45,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Container(
//                       width: 24,
//                       height: 24,
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         shape: BoxShape.circle,
//                       ),
//                       child: Center(
//                         child: Icon(
//                           Icons.arrow_forward_ios_rounded,
//                           color: color,
//                           size: 14,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Trending recipe card
//   Widget _buildTrendingRecipeCard(String title, String category, String time,
//     String imageUrl, dynamic meal) {
//   final mealId = meal['idMeal'];
  
//   return Container(
//     width: 180,
//     margin: const EdgeInsets.only(right: 12),
//     decoration: BoxDecoration(
//       color: cardColor,
//       borderRadius: BorderRadius.circular(12),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 8,
//           offset: const Offset(0, 2),
//         ),
//       ],
//     ),
//     child: InkWell(
//       onTap: () {
//         // Navigate to recipe detail screen
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => RecipeDetailScreen(
//               mealId: meal['idMeal'],
//               mealName: meal['strMeal'],
//               mealImage: meal['strMealThumb'],
//             ),
//           ),
//         );
//       },
//       borderRadius: BorderRadius.circular(12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Image
//           Expanded(
//             child: Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                   ),
//                   child: CachedNetworkImage(
//                     imageUrl: imageUrl,
//                     width: double.infinity,
//                     height: double.infinity,
//                     fit: BoxFit.cover,
//                     placeholder: (context, url) => Shimmer.fromColors(
//                       baseColor: Colors.grey[300]!,
//                       highlightColor: Colors.grey[100]!,
//                       child: Container(
//                         color: Colors.white,
//                       ),
//                     ),
//                     errorWidget: (context, url, error) => Container(
//                       color: Colors.grey.shade200,
//                       width: double.infinity,
//                       child: Center(
//                         child: Icon(
//                           Icons.restaurant_rounded,
//                           size: 40,
//                           color: secondaryTextColor,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Time badge
//                 Positioned(
//                   top: 8,
//                   right: 8,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: cardColor,
//                       borderRadius: BorderRadius.circular(12),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.1),
//                           blurRadius: 4,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.access_time_rounded,
//                           size: 12,
//                           color: accentColor, // Changed to orange accent
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           time,
//                           style: const TextStyle(
//                             fontSize: 10,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Favorite button with StatefulBuilder
//                 Positioned(
//                   top: 8,
//                   left: 8,
//                   child: StatefulBuilder(
//                     builder: (context, setInnerState) {
//                       final isFavorite = _favoriteMeals[mealId] ?? false;
//                       return InkWell(
//                         onTap: () {
//                           _toggleFavorite(meal);
//                           // Force rebuild of just this button
//                           setInnerState(() {});
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(6),
//                           decoration: BoxDecoration(
//                             color: isFavorite
//                                 ? const Color(0xFFE74C3C)
//                                 : cardColor,
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 4,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Icon(
//                             isFavorite
//                                 ? Icons.favorite_rounded
//                                 : Icons.favorite_border_rounded,
//                             color: isFavorite
//                                 ? Colors.white
//                                 : const Color(0xFFE74C3C),
//                             size: 18,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Info
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                     color: textColor,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.category_rounded,
//                       size: 12,
//                       color: secondaryTextColor,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       category,
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: secondaryTextColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

//   // Results tab content
//   Widget _buildResultsTab(List<dynamic> filteredResults) {
//     if (_isLoading) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(
//               color: accentColor, // Changed to orange accent
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Searching...',
//               style: TextStyle(
//                 color: secondaryTextColor,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_errorMessage.isNotEmpty) {
//       return Center(
//         child: _buildErrorState(
//           _errorMessage,
//           'Search Failed',
//           () => _performSearch(_searchController.text),
//         ),
//       );
//     }

//     if (_searchResults.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.search_off_rounded,
//               size: 64,
//               color: secondaryTextColor,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No recipes found',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: textColor,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Try a different search term or browse categories',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: secondaryTextColor,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton.icon(
//               onPressed: () {
//                 _tabController.animateTo(0); // Switch to discover tab
//               },
//               icon: const Icon(Icons.category_rounded),
//               label: const Text('Browse Categories'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: accentColor, // Changed to orange accent
//                 foregroundColor: Colors.white,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return Container(
//       color: backgroundColor,
//       child: Column(
//         children: [
//           // Filter chips
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 12),
//             color: cardColor,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 children: _categories.map((category) {
//                   final isSelected = _selectedCategory == category;
//                   return Padding(
//                     padding: const EdgeInsets.only(right: 8),
//                     child: FilterChip(
//                       label: Text(category),
//                       selected: isSelected,
//                       onSelected: (selected) {
//                         setState(() {
//                           _selectedCategory = category;
//                         });
//                       },
//                       backgroundColor: cardColor,
//                       selectedColor: accentColor.withOpacity(0.1), // Changed to orange accent
//                       checkmarkColor: accentColor, // Changed to orange accent
//                       labelStyle: TextStyle(
//                         color: isSelected ? accentColor : textColor, // Changed to orange accent
//                         fontWeight:
//                             isSelected ? FontWeight.bold : FontWeight.normal,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         side: BorderSide(
//                           color: isSelected ? accentColor : Colors.grey.shade300, // Changed to orange accent
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),

//           // Results count
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             color: cardColor,
//             child: Row(
//               children: [
//                 Text(
//                   '${filteredResults.length} ${filteredResults.length == 1 ? 'recipe' : 'recipes'} found',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: textColor,
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: PopupMenuButton<String>(
//                     icon: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.sort_rounded,
//                           size: 18,
//                           color: secondaryTextColor,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           'Sort',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: secondaryTextColor,
//                           ),
//                         ),
//                         const SizedBox(width: 4),
//                       ],
//                     ),
//                     tooltip: 'Sort by',
//                     onSelected: (value) {
//                       // Implement sorting logic
//                     },
//                     itemBuilder: (context) => [
//                       const PopupMenuItem(
//                         value: 'name_asc',
//                         child: Text('Name (A-Z)'),
//                       ),
//                       const PopupMenuItem(
//                         value: 'name_desc',
//                         child: Text('Name (Z-A)'),
//                       ),
//                     ],
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Results grid
//           Expanded(
//             child: GridView.builder(
//               padding: const EdgeInsets.all(16),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 childAspectRatio: 0.75,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 12,
//               ),
//               itemCount: filteredResults.length,
//               itemBuilder: (context, index) {
//                 final meal = filteredResults[index];
//                 return _buildMealCard(meal, accentColor); // Changed to orange accent
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Recent searches tab content
//   Widget _buildRecentSearchesTab() {
//     if (_recentSearches.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.history_rounded,
//               size: 64,
//               color: secondaryTextColor,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No recent searches',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: textColor,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Your search history will appear here',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: secondaryTextColor,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       );
//     }

//     return Container(
//       color: backgroundColor,
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               SectionHeader(
//                 title: 'Recent Searches',
//                 icon: Icons.history_rounded,
//                 color: textColor,
//               ),
//               TextButton.icon(
//                 onPressed: _clearRecentSearches,
//                 icon: const Icon(Icons.delete_outline_rounded, size: 18),
//                 label: const Text('Clear All'),
//                 style: TextButton.styleFrom(
//                   foregroundColor: accentColor, // Changed to orange accent
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Expanded(
//             child: ListView.builder(
//               itemCount: _recentSearches.length,
//               itemBuilder: (context, index) {
//                 final search = _recentSearches[index];
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 8),
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     side: BorderSide(color: Colors.grey.shade200),
//                   ),
//                   child: ListTile(
//                     leading: Container(
//                       width: 40,
//                       height: 40,
//                       decoration: BoxDecoration(
//                         color: accentColor.withOpacity(0.1), // Changed to orange accent
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.history_rounded,
//                         color: accentColor, // Changed to orange accent
//                       ),
//                     ),
//                     title: Text(
//                       search,
//                       style: TextStyle(
//                         color: textColor,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     trailing: IconButton(
//                       icon: const Icon(Icons.search_rounded),
//                       onPressed: () {
//                         _searchController.text = search;
//                         _performSearch(search);
//                       },
//                       color: accentColor, // Changed to orange accent
//                       tooltip: 'Search again',
//                     ),
//                     onTap: () {
//                       _searchController.text = search;
//                       _performSearch(search);
//                     },
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Meal card for search results
//   Widget _buildMealCard(dynamic meal, Color accentColor) {
//   final mealId = meal['idMeal'];
  
//   return Container(
//     decoration: BoxDecoration(
//       color: cardColor,
//       borderRadius: BorderRadius.circular(12),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 8,
//           offset: const Offset(0, 2),
//         ),
//       ],
//     ),
//     child: InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => RecipeDetailScreen(
//               mealId: meal['idMeal'],
//               mealName: meal['strMeal'],
//               mealImage: meal['strMealThumb'],
//             ),
//           ),
//         );
//       },
//       borderRadius: BorderRadius.circular(12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Image
//           Expanded(
//             child: Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(12),
//                     topRight: Radius.circular(12),
//                   ),
//                   child: CachedNetworkImage(
//                     imageUrl: meal['strMealThumb'],
//                     width: double.infinity,
//                     height: double.infinity,
//                     fit: BoxFit.cover,
//                     placeholder: (context, url) => Shimmer.fromColors(
//                       baseColor: Colors.grey[300]!,
//                       highlightColor: Colors.grey[100]!,
//                       child: Container(
//                         color: Colors.white,
//                       ),
//                     ),
//                     errorWidget: (context, url, error) => Container(
//                       color: Colors.grey.shade200,
//                       width: double.infinity,
//                       child: Center(
//                         child: Icon(
//                           Icons.restaurant_rounded,
//                           size: 40,
//                           color: secondaryTextColor,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Favorite button with StatefulBuilder to ensure it updates
//                 Positioned(
//                   top: 8,
//                   right: 8,
//                   child: StatefulBuilder(
//                     builder: (context, setInnerState) {
//                       final isFavorite = _favoriteMeals[mealId] ?? false;
//                       return InkWell(
//                         onTap: () {
//                           _toggleFavorite(meal);
//                           // Force rebuild of just this button
//                           setInnerState(() {});
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.all(6),
//                           decoration: BoxDecoration(
//                             color: isFavorite
//                                 ? const Color(0xFFE74C3C)
//                                 : cardColor,
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.1),
//                                 blurRadius: 4,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Icon(
//                             isFavorite
//                                 ? Icons.favorite_rounded
//                                 : Icons.favorite_border_rounded,
//                             color: isFavorite
//                                 ? Colors.white
//                                 : const Color(0xFFE74C3C),
//                             size: 18,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Info
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   meal['strMeal'],
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                     color: textColor,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 4),
//                 if (meal['strCategory'] != null)
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.category_rounded,
//                         size: 12,
//                         color: secondaryTextColor,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         meal['strCategory'],
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: secondaryTextColor,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

// // Also update the trending recipe card to use StatefulBuilder for the favorite button

//   // Results tab content

//   // Recent searches tab content
// }

// // Professional search field widget
// class ProfessionalSearchField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hintText;
//   final Function(String)? onChanged;
//   final Function(String)? onSubmitted;
//   final VoidCallback? onClear;

//   const ProfessionalSearchField({
//     Key? key,
//     required this.controller,
//     required this.hintText,
//     this.onChanged,
//     this.onSubmitted,
//     this.onClear,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: Colors.grey.shade300,
//         ),
//       ),
//       child: TextField(
//         controller: controller,
//         onChanged: onChanged,
//         onSubmitted: onSubmitted,
//         decoration: InputDecoration(
//           hintText: hintText,
//           hintStyle: TextStyle(
//             color: Colors.grey.shade500,
//             fontSize: 14,
//           ),
//           prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
//           suffixIcon: controller.text.isNotEmpty
//               ? IconButton(
//                   icon: const Icon(Icons.clear_rounded, color: Colors.grey),
//                   onPressed: onClear,
//                 )
//               : null,
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(
//             vertical: 12,
//             horizontal: 16,
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Section header widget
// class SectionHeader extends StatelessWidget {
//   final String title;
//   final IconData icon;
//   final Color color;

//   const SectionHeader({
//     Key? key,
//     required this.title,
//     required this.icon,
//     required this.color,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           size: 20,
//           color: color,
//         ),
//         const SizedBox(width: 8),
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // Enum for snackbar types
// enum SnackBarType {
//   success,
//   error,
//   warning,
//   info,
// }

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../widgets/app_scaffold.dart';
import '../../widgets/category_detail_screen.dart';
import '../../widgets/recipe_detail_screen.dart' show RecipeDetailScreen;

// Category class for CategoryDetailScreen
class Category {
  final String idCategory;
  final String strCategory;
  final String strCategoryDescription;
  final String strCategoryThumb;

  Category({
    required this.idCategory,
    required this.strCategory,
    required this.strCategoryDescription,
    required this.strCategoryThumb,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  // App theme colors
  final Color primaryColor = const Color(0xFF2C3E50);
  final Color accentColor = const Color(0xFFFF8C00); // Changed to orange
  final Color backgroundColor = const Color(0xFFF5F7FA);
  final Color cardColor = Colors.white;
  final Color textColor = const Color(0xFF2C3E50);
  final Color secondaryTextColor = const Color(0xFF7F8C8D);

  // In-memory storage for recent searches
  List<String> _recentSearches = [];
  List<String> _popularSearches = [
    'Pasta',
    'Chicken',
    'Vegetarian',
    'Dessert',
    'Quick Meals',
    'Breakfast',
    'Italian',
    'Mexican',
    'Healthy',
    'Soup',
    'Salad',
    'Baking'
  ];

  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _showClearButton = false;

  // For filtering
  String _selectedCategory = 'All';
  List<String> _categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Appetizer',
    'Snack'
  ];

  // For favorites
  final Map<String, bool> _favoriteMeals = {};

  // For tabs
  late TabController _tabController;

  // For categories and trending recipes
  List<dynamic> _mealCategories = [];
  List<dynamic> _trendingRecipes = [];
  bool _isLoadingCategories = true;
  bool _isLoadingTrending = true;
  String _categoriesError = '';
  String _trendingError = '';

  // For expanded category
  String? _expandedCategoryId;
  List<dynamic> _categoryMeals = [];
  bool _isLoadingCategoryMeals = false;
  String _categoryMealsError = '';
  
  // For top snackbar
  OverlayEntry? _overlayEntry;
  bool _isSnackbarVisible = false;
  Timer? _snackbarTimer;

  @override
  void initState() {
    super.initState();
    _checkFavorites();
    _tabController = TabController(length: 3, vsync: this);

    _searchController.addListener(() {
      setState(() {
        _showClearButton = _searchController.text.isNotEmpty;
      });
    });

    // Fetch categories and trending recipes when screen loads
    _fetchCategories();
    _fetchTrendingRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose();
    _removeTopSnackBar();
    _snackbarTimer?.cancel();
    super.dispose();
  }

  // Fetch meal categories from MealDB API
  Future<void> _fetchCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://www.themealdb.com/api/json/v1/1/categories.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _mealCategories = data['categories'] ?? [];
          _isLoadingCategories = false;
        });
      } else {
        setState(() {
          _categoriesError =
              'Failed to load categories: ${response.statusCode}';
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      setState(() {
        _categoriesError = 'Error: $e';
        _isLoadingCategories = false;
      });
    }
  }

  // Fetch meals by category from MealDB API
  Future<void> _fetchMealsByCategory(String categoryName) async {
    setState(() {
      _isLoadingCategoryMeals = true;
      _categoryMealsError = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=$categoryName'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _categoryMeals = data['meals'] ?? [];
          _isLoadingCategoryMeals = false;
        });
      } else {
        setState(() {
          _categoryMealsError =
              'Failed to load meals: ${response.statusCode}';
          _isLoadingCategoryMeals = false;
        });
      }
    } catch (e) {
      setState(() {
        _categoryMealsError = 'Error: $e';
        _isLoadingCategoryMeals = false;
      });
    }
  }

  // Toggle category expansion
  void _toggleCategoryExpansion(String categoryId, String categoryName) {
    // Instead of expanding in place, show a modal
    _showCategoryModal(categoryId, categoryName);
  }

  // Show category modal
  void _showCategoryModal(String categoryId, String categoryName) {
    // Find the selected category
    final selectedCategory = _mealCategories.firstWhere(
      (category) => category['idCategory'] == categoryId,
      orElse: () => null,
    );
    
    if (selectedCategory == null) return;
    
    final categoryColor = _getCategoryColor(
      int.parse(selectedCategory['idCategory']) % 10
    );
    
    // Start loading the meals
    setState(() {
      _expandedCategoryId = categoryId;
      _isLoadingCategoryMeals = true;
      _categoryMeals = [];
      _categoryMealsError = '';
    });
    
    // Fetch meals for this category
    _fetchMealsByCategory(categoryName).then((_) {
      if (!mounted) return;
      
      // Show the modal with the fetched meals
      showModalBottomSheet(
  context: context,
  backgroundColor: Colors.transparent,
  isScrollControlled: true,
  builder: (context) => DraggableScrollableSheet(
    initialChildSize: 0.7,
    minChildSize: 0.5,
    maxChildSize: 0.95,
    builder: (_, controller) => Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle indicator
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
          // Header with category name and close button
          Padding(
            padding: const EdgeInsets.only(
                left: 16, right: 16, top: 8, bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: accentColor, // Changed to orange accent
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${selectedCategory['strCategory']} Recipes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  color: secondaryTextColor,
                ),
              ],
            ),
          ),
          
          // Category description
          if (selectedCategory['strCategoryDescription'] != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(
                selectedCategory['strCategoryDescription'],
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          
          // Loading indicator
          if (_isLoadingCategoryMeals)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: CircularProgressIndicator(
                  color: accentColor, // Changed to orange accent
                ),
              ),
            )
          // Error message
          else if (_categoryMealsError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildErrorState(
                _categoryMealsError,
                'Failed to load recipes',
                () {
                  Navigator.of(context).pop();
                  _toggleCategoryExpansion(categoryId, categoryName);
                },
              ),
            )
          // No meals found
          else if (_categoryMeals.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.no_meals_rounded,
                      size: 48,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No recipes found for this category',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          // Meals grid
          else
            Expanded(
              child: GridView.builder(
                controller: controller,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _categoryMeals.length,
                itemBuilder: (context, index) {
                  final meal = _categoryMeals[index];
                  return _buildMealCard(meal, accentColor); // Changed to orange accent
                },
              ),
            ),
        ],
      ),
    ),
  ),
).then((_) {
  // Reset the expanded category when modal is closed
  if (mounted) {
    setState(() {
      _expandedCategoryId = null;
    });
  }
});
    });
  }

  // Fetch trending recipes from MealDB API
  Future<void> _fetchTrendingRecipes() async {
    setState(() {
      _isLoadingTrending = true;
      _trendingError = '';
    });

    try {
      // We'll fetch 5 random meals to simulate trending recipes
      List<dynamic> trendingMeals = [];

      for (int i = 0; i < 5; i++) {
        final response = await http.get(
          Uri.parse('https://www.themealdb.com/api/json/v1/1/random.php'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['meals'] != null && data['meals'].isNotEmpty) {
            trendingMeals.add(data['meals'][0]);
          }
        }
      }

      setState(() {
        _trendingRecipes = trendingMeals;
        _isLoadingTrending = false;
      });
    } catch (e) {
      setState(() {
        _trendingError = 'Error: $e';
        _isLoadingTrending = false;
      });
    }
  }

  // Save a search term to recent searches
  void _saveSearch(String searchTerm) {
    if (searchTerm.trim().isEmpty) return;

    setState(() {
      // Remove if already exists (to move it to the top)
      _recentSearches.remove(searchTerm);

      // Add to the beginning
      _recentSearches.insert(0, searchTerm);

      // Limit to 10 recent searches
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }
    });
  }

  // Clear all recent searches
  void _clearRecentSearches() {
    setState(() {
      _recentSearches = [];
    });
  }

  // Check which meals are already in favorites
  Future<void> _checkFavorites() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final favoritesFile = File('${directory.path}/favorite_recipes.json');

      if (await favoritesFile.exists()) {
        final content = await favoritesFile.readAsString();
        final List<dynamic> favorites = json.decode(content);

        setState(() {
          for (var favorite in favorites) {
            if (favorite['id'] != null) {
              _favoriteMeals[favorite['id']] = true;
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error checking favorites: $e');
    }
  }

  // Toggle favorite status
  void _toggleFavorite(dynamic meal) {
    final mealId = meal['idMeal'];
    final isFavorite = _favoriteMeals[mealId] ?? false;

    // Update the state immediately before the async operations
    setState(() {
      _favoriteMeals[mealId] = !isFavorite;
    });

    // Then handle the database operations
    if (isFavorite) {
      _removeFromFavorites(mealId);
    } else {
      _addMealToFavorites(meal);
    }
  }

  // Add meal to favorites
  Future<void> _addMealToFavorites(dynamic meal) async {
  try {
    // Generate a unique filename for the recipe
    final String fileName = 'recipe_${meal['idMeal']}.pdf';

    // Get the application documents directory
    final directory = await getApplicationDocumentsDirectory();

    // Create recipe metadata
    final Map<String, dynamic> recipeMetadata = {
      'id': meal['idMeal'],
      'name': meal['strMeal'],
      'fileName': fileName,
      'imageUrl': meal['strMealThumb'],
      'date': DateTime.now().toIso8601String(),
      'category': meal['strCategory'] ?? 'Main Course',
      'cuisine': meal['strArea'] ?? 'International',
    };

    // Load existing favorites metadata
    final favoritesFile = File('${directory.path}/favorite_recipes.json');
    List<Map<String, dynamic>> existingFavorites = [];

    if (await favoritesFile.exists()) {
      final content = await favoritesFile.readAsString();
      final List<dynamic> decoded = json.decode(content);
      existingFavorites = List<Map<String, dynamic>>.from(decoded);
    }

    // Check if recipe already exists in favorites
    bool recipeExists =
        existingFavorites.any((favorite) => favorite['id'] == meal['idMeal']);

    if (recipeExists) {
      // ignore: use_build_context_synchronously
      _showTopSnackBar('Recipe is already in your favorites', SnackBarType.warning);
      return;
    }

    // Add new recipe to favorites
    existingFavorites.add(recipeMetadata);

    // Save updated favorites metadata
    await favoritesFile.writeAsString(json.encode(existingFavorites));

    // Show success message
    if (mounted) {
      _showTopSnackBar('Added "${meal['strMeal']}" to favorites', SnackBarType.success);
    }
  } catch (e) {
    debugPrint('Error adding meal to favorites: $e');
    if (mounted) {
      _showTopSnackBar('Failed to add to favorites', SnackBarType.error);
    }
  }
}

  // Remove recipe from favorites
  Future<void> _removeFromFavorites(String mealId) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final favoritesFile = File('${directory.path}/favorite_recipes.json');

    if (await favoritesFile.exists()) {
      final content = await favoritesFile.readAsString();
      List<Map<String, dynamic>> favorites =
          List<Map<String, dynamic>>.from(json.decode(content));
      
      // Find the recipe name before removing it
      String recipeName = "Recipe";
      final recipeToRemove = favorites.firstWhere(
        (favorite) => favorite['id'] == mealId,
        orElse: () => {"name": "Recipe"},
      );
      
      if (recipeToRemove.containsKey("name")) {
        recipeName = recipeToRemove["name"];
      }

      // Remove this recipe from favorites
      favorites.removeWhere((favorite) => favorite['id'] == mealId);

      // Save updated favorites
      await favoritesFile.writeAsString(json.encode(favorites));

      // Show success message
      if (mounted) {
        _showTopSnackBar('Removed "$recipeName" from favorites', SnackBarType.info);
      }
    }
  } catch (e) {
    if (mounted) {
      _showTopSnackBar('Error removing from favorites', SnackBarType.error);
    }
  }
}

  // Remove any existing top snackbar
  void _removeTopSnackBar() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isSnackbarVisible = false;
    _snackbarTimer?.cancel();
  }

  // Show custom top snackbar
  void _showTopSnackBar(String message, SnackBarType type) {
    // If there's already a snackbar showing, remove it first
    if (_isSnackbarVisible) {
      _removeTopSnackBar();
    }

    Color backgroundColor;
    Color textColor = Colors.white;
    IconData icon;
    
    // Determine colors and icon based on snackbar type
    switch (type) {
      case SnackBarType.success:
        backgroundColor = const Color(0xFF2ECC71);
        icon = Icons.check_circle_rounded;
        break;
      case SnackBarType.error:
        backgroundColor = const Color(0xFFE74C3C);
        icon = Icons.error_rounded;
        break;
      case SnackBarType.warning:
        backgroundColor = const Color(0xFFF39C12);
        icon = Icons.warning_rounded;
        break;
      case SnackBarType.info:
        backgroundColor = accentColor;
        icon = Icons.info_rounded;
        break;
    }

    // Create the overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).viewPadding.top + 10,
        left: 10,
        right: 10,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: textColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: textColor.withOpacity(0.8), size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _removeTopSnackBar,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Show the overlay
    Overlay.of(context).insert(_overlayEntry!);
    _isSnackbarVisible = true;

    // Auto-dismiss after 3 seconds
    _snackbarTimer = Timer(const Duration(seconds: 3), () {
      _removeTopSnackBar();
    });
  }

  // Open favorites bottom sheet
  void _openFavoritesBottomSheet() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final favoritesFile = File('${directory.path}/favorite_recipes.json');

      List<Map<String, dynamic>> favoriteRecipes = [];
      if (await favoritesFile.exists()) {
        final content = await favoritesFile.readAsString();
        favoriteRecipes = List<Map<String, dynamic>>.from(json.decode(content));
      }

      if (favoriteRecipes.isEmpty) {
        _showTopSnackBar('No favorite recipes yet', SnackBarType.info);
        return;
      }

      // Sort by date (newest first)
      favoriteRecipes.sort((a, b) =>
          DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

      if (mounted) {
        showModalBottomSheet(
  context: context,
  backgroundColor: Colors.transparent,
  isScrollControlled: true,
  builder: (context) => DraggableScrollableSheet(
    initialChildSize: 0.7,
    minChildSize: 0.5,
    maxChildSize: 0.95,
    builder: (_, controller) => Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle indicator
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.only(
                left: 16, right: 16, top: 8, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Favorite Recipes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  color: secondaryTextColor,
                ),
              ],
            ),
          ),
          // Favorited recipes list
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: favoriteRecipes.length,
              itemBuilder: (context, index) {
                final recipe = favoriteRecipes[index];
                final date = DateTime.parse(recipe['date']);
                final now = DateTime.now();

                String formattedDate;
                if (now.difference(date).inDays == 0) {
                  formattedDate = 'Today';
                } else if (now.difference(date).inDays == 1) {
                  formattedDate = 'Yesterday';
                } else {
                  formattedDate =
                      '${date.day}/${date.month}/${date.year}';
                }

                return _buildFavoriteCard(recipe, formattedDate);
              },
            ),
          ),
        ],
      ),
    ),
  ),
);
      }
    } catch (e) {
      _showTopSnackBar('Error loading favorites', SnackBarType.error);
    }
  }

  // Build a card for favorite recipes
  Widget _buildFavoriteCard(Map<String, dynamic> recipe, String date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(
                mealId: recipe['id'],
                mealName: recipe['name'],
                mealImage: recipe['imageUrl'],
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Recipe image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: recipe['imageUrl'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 80,
                      height: 80,
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.image_not_supported_rounded,
                      size: 30,
                      color: secondaryTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Recipe details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipe name
                    Text(
                      recipe['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Category and cuisine
                    Row(
                      children: [
                        Icon(
                          Icons.category_rounded,
                          size: 14,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe['category'] ?? 'Main Course',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.public_rounded,
                          size: 14,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe['cuisine'] ?? 'International',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Added date
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Added: $date',
                          style: TextStyle(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // View button
              Container(
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1), // Changed to orange accent
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: accentColor, // Changed to orange accent
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(
                          mealId: recipe['id'],
                          mealName: recipe['name'],
                          mealImage: recipe['imageUrl'],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Perform search
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Save to recent searches (no await needed now)
      _saveSearch(query);

      // API call to search for meals
      final response = await http.get(
        Uri.parse(
            'https://www.themealdb.com/api/json/v1/1/search.php?s=${query.trim()}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data['meals'] ?? [];
          _isLoading = false;

          // Switch to results tab if we have results
          if (_searchResults.isNotEmpty) {
            _tabController.animateTo(1); // Results tab
          }
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load search results: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  // Filter search results by category
  List<dynamic> _getFilteredResults() {
    if (_selectedCategory == 'All') {
      return _searchResults;
    }

    return _searchResults.where((meal) {
      final category = meal['strCategory'] ?? '';
      return category.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredResults = _getFilteredResults();

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Culinary Explorer',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: cardColor,
        foregroundColor: textColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_rounded),
            onPressed: _openFavoritesBottomSheet,
            color: const Color(0xFFE74C3C),
          ),
        ],
      ),
      body: Container(
        color: backgroundColor,
        child: Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ProfessionalSearchField(
                    controller: _searchController,
                    hintText: 'Search for recipes, ingredients...',
                    onChanged: (value) {
                      // We'll handle search on submit
                    },
                    onClear: () {
                      _searchController.clear();
                      setState(() {
                        _showClearButton = false;
                      });
                    },
                    onSubmitted: (value) => _performSearch(value),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _performSearch(_searchController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor, // Changed to orange accent
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Search',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab bar
            Container(
              color: cardColor,
              child: TabBar(
                controller: _tabController,
                labelColor: accentColor, // Changed to orange accent
                unselectedLabelColor: secondaryTextColor,
                indicatorColor: accentColor, // Changed to orange accent
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                tabs: const [
                  Tab(text: 'DISCOVER'),
                  Tab(text: 'RESULTS'),
                  Tab(text: 'RECENT'),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Discover tab
                  _buildDiscoverTab(),

                  // Results tab
                  _buildResultsTab(filteredResults),

                  // Recent searches tab
                  _buildRecentSearchesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Discover tab content
  Widget _buildDiscoverTab() {
    return Container(
      color: backgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Popular searches section
            SectionHeader(
              title: 'Popular Searches',
              icon: Icons.trending_up_rounded,
              color: textColor,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularSearches.map((search) {
                return InkWell(
                  onTap: () {
                    _searchController.text = search;
                    _performSearch(search);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Text(
                      search,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Categories section
            SectionHeader(
              title: 'Browse by Category',
              icon: Icons.category_rounded,
              color: textColor,
            ),
            const SizedBox(height: 12),

            // Categories grid with loading state
            _isLoadingCategories
              ? _buildLoadingCategories()
              : _categoriesError.isNotEmpty
                ? _buildErrorState(
                    _categoriesError,
                    'Failed to load categories',
                    _fetchCategories,
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _mealCategories.length,
                    itemBuilder: (context, index) {
                      final category = _mealCategories[index];
                      final isExpanded = _expandedCategoryId == category['idCategory'];
                      
                      return _buildCategoryCard(
                        category['strCategory'],
                        category['strCategoryThumb'],
                        _getCategoryColor(index),
                        category,
                        isExpanded,
                      );
                    },
                  ),

            const SizedBox(height: 24),

            // Trending recipes section
            SectionHeader(
              title: 'Trending Recipes',
              icon: Icons.local_fire_department_rounded,
              color: textColor,
            ),
            const SizedBox(height: 12),

            // Trending recipes with loading state
            _isLoadingTrending
              ? _buildLoadingTrendingRecipes()
              : _trendingError.isNotEmpty
                ? _buildErrorState(
                    _trendingError,
                    'Failed to load trending recipes',
                    _fetchTrendingRecipes,
                  )
                : SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _trendingRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _trendingRecipes[index];
                        return _buildTrendingRecipeCard(
                          recipe['strMeal'],
                          recipe['strCategory'] ?? 'Main Course',
                          '${15 + (recipe['idMeal'].hashCode % 30)} min',
                          recipe['strMealThumb'],
                          recipe,
                        );
                      },
                    ),
                  ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Loading state for categories
  Widget _buildLoadingCategories() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  // Loading state for trending recipes
  Widget _buildLoadingTrendingRecipes() {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }

  // Error state widget
  Widget _buildErrorState(String error, String message, VoidCallback onRetry) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: const Color(0xFFE74C3C),
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor, // Changed to orange accent
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Get a color for a category based on its index
  Color _getCategoryColor(int index) {
    final colors = [
      accentColor, // Changed to orange accent (primary)
      const Color(0xFF2ECC71), // Green
      const Color(0xFFE74C3C), // Red
      const Color(0xFF9B59B6), // Purple
      const Color(0xFFF39C12), // Orange
      const Color(0xFF1ABC9C), // Teal
      const Color(0xFFD35400), // Dark Orange
      const Color(0xFF8E44AD), // Dark Purple
      const Color(0xFF2980B9), // Dark Blue
      const Color(0xFF27AE60), // Dark Green
    ];

    return colors[index % colors.length];
  }

  // Category card for browse by category
  Widget _buildCategoryCard(
      String title, String imageUrl, Color color, dynamic category, bool isExpanded) {
    return InkWell(
      onTap: () {
        // Toggle category expansion instead of navigating
        _toggleCategoryExpansion(category['idCategory'], category['strCategory']);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image background
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: color.withOpacity(0.1),
                  child: Center(
                    child: Icon(
                      Icons.restaurant_rounded,
                      size: 40,
                      color: color.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
            
            // Gradient overlay
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            
            // Category name and icon
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 3,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: color,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Trending recipe card
  Widget _buildTrendingRecipeCard(String title, String category, String time,
    String imageUrl, dynamic meal) {
  final mealId = meal['idMeal'];
  
  return Container(
    width: 180,
    margin: const EdgeInsets.only(right: 12),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: InkWell(
      onTap: () {
        // Navigate to recipe detail screen
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
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade200,
                      width: double.infinity,
                      child: Center(
                        child: Icon(
                          Icons.restaurant_rounded,
                          size: 40,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
                // Time badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: accentColor, // Changed to orange accent
                        ),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Favorite button with StatefulBuilder
                Positioned(
                  top: 8,
                  left: 8,
                  child: StatefulBuilder(
                    builder: (context, setInnerState) {
                      final isFavorite = _favoriteMeals[mealId] ?? false;
                      return InkWell(
                        onTap: () {
                          _toggleFavorite(meal);
                          // Force rebuild of just this button
                          setInnerState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isFavorite
                                ? const Color(0xFFE74C3C)
                                : cardColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorite
                                ? Colors.white
                                : const Color(0xFFE74C3C),
                            size: 18,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.category_rounded,
                      size: 12,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  // Results tab content
  Widget _buildResultsTab(List<dynamic> filteredResults) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: accentColor, // Changed to orange accent
            ),
            const SizedBox(height: 16),
            Text(
              'Searching...',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: _buildErrorState(
          _errorMessage,
          'Search Failed',
          () => _performSearch(_searchController.text),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No recipes found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term or browse categories',
              style: TextStyle(
                fontSize: 16,
                color: secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _tabController.animateTo(0); // Switch to discover tab
              },
              icon: const Icon(Icons.category_rounded),
              label: const Text('Browse Categories'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor, // Changed to orange accent
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: cardColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: cardColor,
                      selectedColor: accentColor.withOpacity(0.1), // Changed to orange accent
                      checkmarkColor: accentColor, // Changed to orange accent
                      labelStyle: TextStyle(
                        color: isSelected ? accentColor : textColor, // Changed to orange accent
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected ? accentColor : Colors.grey.shade300, // Changed to orange accent
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Results count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: cardColor,
            child: Row(
              children: [
                Text(
                  '${filteredResults.length} ${filteredResults.length == 1 ? 'recipe' : 'recipes'} found',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: PopupMenuButton<String>(
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sort_rounded,
                          size: 18,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Sort',
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                    tooltip: 'Sort by',
                    onSelected: (value) {
                      // Implement sorting logic
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'name_asc',
                        child: Text('Name (A-Z)'),
                      ),
                      const PopupMenuItem(
                        value: 'name_desc',
                        child: Text('Name (Z-A)'),
                      ),
                    ],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filteredResults.length,
              itemBuilder: (context, index) {
                final meal = filteredResults[index];
                return _buildMealCard(meal, accentColor); // Changed to orange accent
              },
            ),
          ),
        ],
      ),
    );
  }

  // Recent searches tab content
  Widget _buildRecentSearchesTab() {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 64,
              color: secondaryTextColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No recent searches',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your search history will appear here',
              style: TextStyle(
                fontSize: 16,
                color: secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SectionHeader(
                title: 'Recent Searches',
                icon: Icons.history_rounded,
                color: textColor,
              ),
              TextButton.icon(
                onPressed: _clearRecentSearches,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(
                  foregroundColor: accentColor, // Changed to orange accent
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: _recentSearches.length,
              itemBuilder: (context, index) {
                final search = _recentSearches[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1), // Changed to orange accent
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        color: accentColor, // Changed to orange accent
                      ),
                    ),
                    title: Text(
                      search,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.search_rounded),
                      onPressed: () {
                        _searchController.text = search;
                        _performSearch(search);
                      },
                      color: accentColor, // Changed to orange accent
                      tooltip: 'Search again',
                    ),
                    onTap: () {
                      _searchController.text = search;
                      _performSearch(search);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Meal card for search results
  Widget _buildMealCard(dynamic meal, Color accentColor) {
  final mealId = meal['idMeal'];
  
  return Container(
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: InkWell(
      onTap: () {
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
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: meal['strMealThumb'],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade200,
                      width: double.infinity,
                      child: Center(
                        child: Icon(
                          Icons.restaurant_rounded,
                          size: 40,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
                // Favorite button with StatefulBuilder to ensure it updates
                Positioned(
                  top: 8,
                  right: 8,
                  child: StatefulBuilder(
                    builder: (context, setInnerState) {
                      final isFavorite = _favoriteMeals[mealId] ?? false;
                      return InkWell(
                        onTap: () {
                          _toggleFavorite(meal);
                          // Force rebuild of just this button
                          setInnerState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isFavorite
                                ? const Color(0xFFE74C3C)
                                : cardColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorite
                                ? Colors.white
                                : const Color(0xFFE74C3C),
                            size: 18,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal['strMeal'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (meal['strCategory'] != null)
                  Row(
                    children: [
                      Icon(
                        Icons.category_rounded,
                        size: 12,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        meal['strCategory'],
                        style: TextStyle(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Also update the trending recipe card to use StatefulBuilder for the favorite button

  // Results tab content

  // Recent searches tab content
}

// Professional search field widget
class ProfessionalSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onClear;

  const ProfessionalSearchField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}

// Section header widget
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const SectionHeader({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// Enum for snackbar types
enum SnackBarType {
  success,
  error,
  warning,
  info,
}

