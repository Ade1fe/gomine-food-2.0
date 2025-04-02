// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';

// import '../../widgets/app_scaffold.dart';
// import '../../widgets/category_detail_screen.dart';
// import '../../widgets/recipe_detail_screen.dart' show RecipeDetailScreen;

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});

//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _searchController = TextEditingController();
//   final FocusNode _searchFocusNode = FocusNode();
//   final Color primaryColor = Colors.deepOrange;

//   // In-memory storage for recent searches
//   List<String> _recentSearches = [];
//   List<String> _popularSearches = [
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

//   // Fetch trending recipes from MealDB API
//   // Since MealDB doesn't have a "trending" endpoint, we'll use random meals
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

//     if (isFavorite) {
//       _removeFromFavorites(mealId);
//     } else {
//       _addMealToFavorites(meal);
//     }

//     setState(() {
//       _favoriteMeals[mealId] = !isFavorite;
//     });
//   }

//   // Add meal to favorites
//   Future<void> _addMealToFavorites(dynamic meal) async {
//     try {
//       // Generate a unique filename for the recipe
//       final String fileName = 'recipe_${meal['idMeal']}.pdf';

//       // Get the application documents directory
//       final directory = await getApplicationDocumentsDirectory();

//       // Create recipe metadata
//       final Map<String, dynamic> recipeMetadata = {
//         'id': meal['idMeal'],
//         'name': meal['strMeal'],
//         'fileName': fileName,
//         'imageUrl': meal['strMealThumb'],
//         'date': DateTime.now().toIso8601String(),
//         'category': meal['strCategory'] ?? 'Main Course',
//         'cuisine': meal['strArea'] ?? 'International',
//       };

//       // Load existing favorites metadata
//       final favoritesFile = File('${directory.path}/favorite_recipes.json');
//       List<Map<String, dynamic>> existingFavorites = [];

//       if (await favoritesFile.exists()) {
//         final content = await favoritesFile.readAsString();
//         final List<dynamic> decoded = json.decode(content);
//         existingFavorites = List<Map<String, dynamic>>.from(decoded);
//       }

//       // Check if recipe already exists in favorites
//       bool recipeExists =
//           existingFavorites.any((favorite) => favorite['id'] == meal['idMeal']);

//       if (recipeExists) {
//         // ignore: use_build_context_synchronously
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Recipe is already in favorites'),
//             backgroundColor: Colors.orange,
//           ),
//         );
//         return;
//       }

//       // Add new recipe to favorites
//       existingFavorites.add(recipeMetadata);

//       // Save updated favorites metadata
//       await favoritesFile.writeAsString(json.encode(existingFavorites));

//       // Show success message
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Added ${meal['strMeal']} to favorites'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('Error adding meal to favorites: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to add to favorites: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   // Remove recipe from favorites
//   Future<void> _removeFromFavorites(String mealId) async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final favoritesFile = File('${directory.path}/favorite_recipes.json');

//       if (await favoritesFile.exists()) {
//         final content = await favoritesFile.readAsString();
//         List<Map<String, dynamic>> favorites =
//             List<Map<String, dynamic>>.from(json.decode(content));

//         // Remove this recipe from favorites
//         favorites.removeWhere((favorite) => favorite['id'] == mealId);

//         // Save updated favorites
//         await favoritesFile.writeAsString(json.encode(favorites));

//         // Show success message
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Removed from favorites'),
//               backgroundColor: Colors.grey,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error removing from favorites: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
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
//         // ignore: use_build_context_synchronously
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('No favorite recipes yet'),
//             backgroundColor: Colors.grey,
//           ),
//         );
//         return;
//       }

//       // Sort by date (newest first)
//       favoriteRecipes.sort((a, b) =>
//           DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

//       if (mounted) {
//         showModalBottomSheet(
//           context: context,
//           backgroundColor: Colors.transparent,
//           isScrollControlled: true,
//           builder: (context) => DraggableScrollableSheet(
//             initialChildSize: 0.7,
//             minChildSize: 0.5,
//             maxChildSize: 0.95,
//             builder: (_, controller) => Container(
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Handle indicator
//                   Center(
//                     child: Container(
//                       width: 40,
//                       height: 5,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       margin: const EdgeInsets.symmetric(vertical: 8),
//                     ),
//                   ),
//                   // Header
//                   Padding(
//                     padding: const EdgeInsets.only(
//                         left: 16, right: 16, top: 8, bottom: 16),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Your Favorite Recipes',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.close),
//                           onPressed: () => Navigator.of(context).pop(),
//                           color: Colors.grey[700],
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Favorited recipes list
//                   Expanded(
//                     child: ListView.builder(
//                       controller: controller,
//                       itemCount: favoriteRecipes.length,
//                       itemBuilder: (context, index) {
//                         final recipe = favoriteRecipes[index];
//                         final date = DateTime.parse(recipe['date']);
//                         final now = DateTime.now();

//                         String formattedDate;
//                         if (now.difference(date).inDays == 0) {
//                           formattedDate = 'Today';
//                         } else if (now.difference(date).inDays == 1) {
//                           formattedDate = 'Yesterday';
//                         } else {
//                           formattedDate =
//                               '${date.day}/${date.month}/${date.year}';
//                         }

//                         return _buildFavoriteCard(recipe, formattedDate);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       // ignore: use_build_context_synchronously
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error loading favorites: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // Build a card for favorite recipes
//   Widget _buildFavoriteCard(Map<String, dynamic> recipe, String date) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
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
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.network(
//                   recipe['imageUrl'],
//                   width: 80,
//                   height: 80,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       width: 80,
//                       height: 80,
//                       color: Colors.grey.shade300,
//                       child: const Icon(Icons.image_not_supported,
//                           size: 40, color: Colors.grey),
//                     );
//                   },
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
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     // Category and cuisine
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.category,
//                           size: 14,
//                           color: Colors.grey.shade600,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           recipe['category'] ?? 'Main Course',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Icon(
//                           Icons.public,
//                           size: 14,
//                           color: Colors.grey.shade600,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           recipe['cuisine'] ?? 'International',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     // Added date
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.access_time,
//                           size: 14,
//                           color: Colors.grey.shade600,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           'Added: $date',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               // View button
//               IconButton(
//                 icon: const Icon(
//                   Icons.arrow_forward_ios,
//                   size: 16,
//                   color: Colors.pink,
//                 ),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => RecipeDetailScreen(
//                         mealId: recipe['id'],
//                         mealName: recipe['name'],
//                         mealImage: recipe['imageUrl'],
//                       ),
//                     ),
//                   );
//                 },
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
//         title: const Text(
//           'Search Recipes',
//           style: TextStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               // Search bar
//               Container(
//                 padding: const EdgeInsets.all(16.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withValues(alpha: .05),
//                       blurRadius: 10,
//                       spreadRadius: 0,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     CustomSearchField(
//                       controller: _searchController,
//                       hintText: 'Search for recipes, ingredients...',
//                       onChanged: (value) {
//                         // We'll handle search on submit
//                       },
//                       onClear: () {
//                         _searchController.clear();
//                         setState(() {
//                           _showClearButton = false;
//                         });
//                       },
//                       backgroundColor: Colors.grey.shade100,
//                     ),
//                     const SizedBox(height: 8),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: () => _performSearch(_searchController.text),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: primaryColor,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(25),
//                           ),
//                         ),
//                         child: const Text(
//                           'Search',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Tab bar
//               Container(
//                 color: Colors.white,
//                 child: TabBar(
//                   controller: _tabController,
//                   labelColor: primaryColor,
//                   unselectedLabelColor: Colors.grey,
//                   indicatorColor: primaryColor,
//                   indicatorSize: TabBarIndicatorSize.label,
//                   labelStyle: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                   ),
//                   tabs: const [
//                     Tab(text: 'DISCOVER'),
//                     Tab(text: 'RESULTS'),
//                     Tab(text: 'RECENT'),
//                   ],
//                 ),
//               ),

//               // Tab content
//               Expanded(
//                 child: TabBarView(
//                   controller: _tabController,
//                   children: [
//                     // Discover tab
//                     _buildDiscoverTab(),

//                     // Results tab
//                     _buildResultsTab(filteredResults),

//                     // Recent searches tab
//                     _buildRecentSearchesTab(),
//                   ],
//                 ),
//               ),
//             ],
//           ),

//           // Floating favorite button at bottom left
//           Positioned(
//             bottom: 20,
//             left: 20,
//             child: FloatingActionButton(
//               heroTag: 'favoritesBtn',
//               onPressed: _openFavoritesBottomSheet,
//               backgroundColor: Colors.pink,
//               child: const Icon(Icons.favorite),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Discover tab content
//   Widget _buildDiscoverTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Popular searches section
//           const Text(
//             'Popular Searches',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: _popularSearches.map((search) {
//               return InkWell(
//                 onTap: () {
//                   _searchController.text = search;
//                   _performSearch(search);
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                       color: Colors.grey.shade300,
//                     ),
//                   ),
//                   child: Text(
//                     search,
//                     style: TextStyle(
//                       color: Colors.grey.shade800,
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),

//           const SizedBox(height: 32),

//           // Categories section
//           const Text(
//             'Browse by Category',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Categories grid with loading state
//           _isLoadingCategories
//               ? Center(
//                   child: CircularProgressIndicator(
//                     color: primaryColor,
//                   ),
//                 )
//               : _categoriesError.isNotEmpty
//                   ? Center(
//                       child: Column(
//                         children: [
//                           const Icon(Icons.error_outline,
//                               color: Colors.red, size: 48),
//                           const SizedBox(height: 16),
//                           Text(_categoriesError),
//                           const SizedBox(height: 16),
//                           ElevatedButton(
//                             onPressed: _fetchCategories,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: primaryColor,
//                               foregroundColor: Colors.white,
//                             ),
//                             child: const Text('Try Again'),
//                           ),
//                         ],
//                       ),
//                     )
//                   : GridView.builder(
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         childAspectRatio: 1.5,
//                         crossAxisSpacing: 16,
//                         mainAxisSpacing: 16,
//                       ),
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: _mealCategories.length,
//                       itemBuilder: (context, index) {
//                         final category = _mealCategories[index];
//                         return _buildCategoryCard(
//                           category['strCategory'],
//                           category['strCategoryThumb'],
//                           _getCategoryColor(index),
//                           category,
//                         );
//                       },
//                     ),

//           const SizedBox(height: 32),

//           // Trending recipes section
//           const Text(
//             'Trending Recipes',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Trending recipes with loading state
//           _isLoadingTrending
//               ? Center(
//                   child: SizedBox(
//                     height: 200,
//                     child: Center(
//                       child: CircularProgressIndicator(
//                         color: primaryColor,
//                       ),
//                     ),
//                   ),
//                 )
//               : _trendingError.isNotEmpty
//                   ? Center(
//                       child: Column(
//                         children: [
//                           const Icon(Icons.error_outline,
//                               color: Colors.red, size: 48),
//                           const SizedBox(height: 16),
//                           Text(_trendingError),
//                           const SizedBox(height: 16),
//                           ElevatedButton(
//                             onPressed: _fetchTrendingRecipes,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: primaryColor,
//                               foregroundColor: Colors.white,
//                             ),
//                             child: const Text('Try Again'),
//                           ),
//                         ],
//                       ),
//                     )
//                   : SizedBox(
//                       height: 200,
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: _trendingRecipes.length,
//                         itemBuilder: (context, index) {
//                           final recipe = _trendingRecipes[index];
//                           return _buildTrendingRecipeCard(
//                             recipe['strMeal'],
//                             recipe['strCategory'] ?? 'Main Course',
//                             '${15 + (recipe['idMeal'].hashCode % 30)} min',
//                             recipe['strMealThumb'],
//                             recipe,
//                           );
//                         },
//                       ),
//                     ),

//           const SizedBox(height: 32),
//         ],
//       ),
//     );
//   }

//   // Get a color for a category based on its index
//   Color _getCategoryColor(int index) {
//     final colors = [
//       Colors.orange,
//       Colors.green,
//       Colors.blue,
//       Colors.pink,
//       Colors.purple,
//       Colors.amber,
//       Colors.teal,
//       Colors.indigo,
//       Colors.red,
//       Colors.brown,
//     ];

//     return colors[index % colors.length];
//   }

//   // Category card for browse by category
//   Widget _buildCategoryCard(
//       String title, String imageUrl, Color color, dynamic category) {
//     return InkWell(
//       onTap: () {
//         // Navigate to category detail screen
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => CategoryDetailScreen(
//               category: category,
//               cookingTime: '${15 + (category['idCategory'].hashCode % 30)} min',
//             ),
//           ),
//         );
//       },
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(16),
//             child: Image.network(
//               imageUrl,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   color: color.withValues(alpha: .2),
//                   child: Center(
//                     child: Icon(
//                       Icons.restaurant,
//                       size: 40,
//                       color: color.withValues(alpha: .5),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.black.withValues(alpha: .6),
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(16),
//                   bottomRight: Radius.circular(16),
//                 ),
//               ),
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Trending recipe card
//   Widget _buildTrendingRecipeCard(String title, String category, String time,
//       String imageUrl, dynamic meal) {
//     return Container(
//       width: 160,
//       margin: const EdgeInsets.only(right: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: .05),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: InkWell(
//         onTap: () {
//           // Navigate to recipe detail screen
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => RecipeDetailScreen(
//                 mealId: meal['idMeal'],
//                 mealName: meal['strMeal'],
//                 mealImage: meal['strMealThumb'],
//               ),
//             ),
//           );
//         },
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image
//             Expanded(
//               child: Stack(
//                 children: [
//                   ClipRRect(
//                     borderRadius: const BorderRadius.only(
//                       topLeft: Radius.circular(16),
//                       topRight: Radius.circular(16),
//                     ),
//                     child: Image.network(
//                       imageUrl,
//                       width: double.infinity,
//                       height: double.infinity,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Container(
//                           color: Colors.grey.shade300,
//                           width: double.infinity,
//                           child: Center(
//                             child: Icon(
//                               Icons.restaurant,
//                               size: 40,
//                               color: Colors.grey.shade400,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                   // Time badge
//                   Positioned(
//                     top: 8,
//                     right: 8,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withValues(alpha: .1),
//                             blurRadius: 4,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(
//                             Icons.access_time,
//                             size: 12,
//                             color: Colors.deepOrange,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             time,
//                             style: const TextStyle(
//                               fontSize: 10,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   // Favorite button
//                   Positioned(
//                     top: 8,
//                     left: 8,
//                     child: InkWell(
//                       onTap: () => _toggleFavorite(meal),
//                       child: Container(
//                         padding: const EdgeInsets.all(6),
//                         decoration: BoxDecoration(
//                           color: _favoriteMeals[meal['idMeal']] ?? false
//                               ? Colors.pink
//                               : Colors.white,
//                           shape: BoxShape.circle,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withValues(alpha: .1),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Icon(
//                           _favoriteMeals[meal['idMeal']] ?? false
//                               ? Icons.favorite
//                               : Icons.favorite_border,
//                           color: _favoriteMeals[meal['idMeal']] ?? false
//                               ? Colors.white
//                               : Colors.red,
//                           size: 18,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             // Info
//             Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 14,
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     category,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Results tab content
//   Widget _buildResultsTab(List<dynamic> filteredResults) {
//     if (_isLoading) {
//       return Center(
//         child: CircularProgressIndicator(
//           color: primaryColor,
//         ),
//       );
//     }

//     if (_errorMessage.isNotEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, size: 48, color: Colors.red),
//             const SizedBox(height: 16),
//             Text(
//               _errorMessage,
//               style: const TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => _performSearch(_searchController.text),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryColor,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text('Try Again'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_searchResults.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.search_off,
//               size: 64,
//               color: primaryColor.withValues(alpha: .5),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'No recipes found',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Try a different search term or browse categories',
//               style: TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () {
//                 _tabController.animateTo(0); // Switch to discover tab
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryColor,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text('Browse Categories'),
//             ),
//           ],
//         ),
//       );
//     }

//     return Column(
//       children: [
//         // Filter chips
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           color: Colors.white,
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(
//               children: _categories.map((category) {
//                 final isSelected = _selectedCategory == category;
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 8),
//                   child: FilterChip(
//                     label: Text(category),
//                     selected: isSelected,
//                     onSelected: (selected) {
//                       setState(() {
//                         _selectedCategory = category;
//                       });
//                     },
//                     backgroundColor: Colors.grey.shade100,
//                     selectedColor: primaryColor.withValues(alpha: .2),
//                     checkmarkColor: primaryColor,
//                     labelStyle: TextStyle(
//                       color: isSelected ? primaryColor : Colors.black87,
//                       fontWeight:
//                           isSelected ? FontWeight.bold : FontWeight.normal,
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ),

//         // Results count
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Row(
//             children: [
//               Text(
//                 '${filteredResults.length} ${filteredResults.length == 1 ? 'result' : 'results'} found',
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const Spacer(),
//               PopupMenuButton<String>(
//                 icon: const Icon(Icons.sort),
//                 tooltip: 'Sort by',
//                 onSelected: (value) {
//                   // Implement sorting logic
//                 },
//                 itemBuilder: (context) => [
//                   const PopupMenuItem(
//                     value: 'name_asc',
//                     child: Text('Name (A-Z)'),
//                   ),
//                   const PopupMenuItem(
//                     value: 'name_desc',
//                     child: Text('Name (Z-A)'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),

//         // Results grid
//         Expanded(
//           child: GridView.builder(
//             padding: const EdgeInsets.all(16),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 0.8,
//               crossAxisSpacing: 16,
//               mainAxisSpacing: 16,
//             ),
//             itemCount: filteredResults.length,
//             itemBuilder: (context, index) {
//               final meal = filteredResults[index];
//               return _buildMealCard(meal);
//             },
//           ),
//         ),
//       ],
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
//               Icons.history,
//               size: 64,
//               color: Colors.grey.shade400,
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'No recent searches',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Your search history will appear here',
//               style: TextStyle(fontSize: 16),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () {
//                 _tabController.animateTo(0); // Switch to discover tab
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryColor,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text('Start Searching'),
//             ),
//           ],
//         ),
//       );
//     }

//     return Column(
//       children: [
//         // Header with clear button
//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Recent Searches',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               TextButton.icon(
//                 onPressed: _clearRecentSearches,
//                 icon: const Icon(Icons.delete_outline, size: 18),
//                 label: const Text('Clear All'),
//                 style: TextButton.styleFrom(
//                   foregroundColor: Colors.red,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // Recent searches list
//         Expanded(
//           child: ListView.separated(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             itemCount: _recentSearches.length,
//             separatorBuilder: (context, index) => const Divider(),
//             itemBuilder: (context, index) {
//               final search = _recentSearches[index];
//               return ListTile(
//                 leading: const Icon(Icons.history),
//                 title: Text(search),
//                 trailing: IconButton(
//                   icon: const Icon(Icons.search),
//                   onPressed: () {
//                     _searchController.text = search;
//                     _performSearch(search);
//                   },
//                 ),
//                 onTap: () {
//                   _searchController.text = search;
//                   _performSearch(search);
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   // Meal card for search results
//   Widget _buildMealCard(dynamic meal) {
//     final mealId = meal['idMeal'];
//     final isFavorite = _favoriteMeals[mealId] ?? false;

//     return GestureDetector(
//       onTap: () {
//         // Navigate to meal detail screen
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
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withValues(alpha: .05),
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
//                       meal['strMealThumb'],
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
//                               color: primaryColor,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     // Favorite button
//                     Positioned(
//                       top: 8,
//                       right: 8,
//                       child: InkWell(
//                         onTap: () => _toggleFavorite(meal),
//                         child: Container(
//                           padding: const EdgeInsets.all(6),
//                           decoration: BoxDecoration(
//                             color: isFavorite ? Colors.pink : Colors.white,
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withValues(alpha: .1),
//                                 blurRadius: 4,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Icon(
//                             isFavorite ? Icons.favorite : Icons.favorite_border,
//                             color: isFavorite ? Colors.white : Colors.red,
//                             size: 18,
//                           ),
//                         ),
//                       ),
//                     ),
//                     // Category badge
//                     if (meal['strCategory'] != null)
//                       Positioned(
//                         bottom: 0,
//                         left: 0,
//                         right: 0,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(vertical: 4),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               begin: Alignment.topCenter,
//                               end: Alignment.bottomCenter,
//                               colors: [
//                                 Colors.transparent,
//                                 Colors.black.withValues(alpha: .7),
//                               ],
//                             ),
//                           ),
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8),
//                             child: Text(
//                               meal['strCategory'],
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               // Meal info
//               Padding(
//                 padding: const EdgeInsets.all(12.0),
//                 child: Text(
//                   meal['strMeal'],
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Custom search field widget
// class CustomSearchField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hintText;
//   final Function(String) onChanged;
//   final VoidCallback onClear;
//   final Color backgroundColor;
//   final Color color;

//   const CustomSearchField({
//     super.key,
//     required this.controller,
//     required this.hintText,
//     required this.onChanged,
//     required this.onClear,
//     this.backgroundColor = Colors.white,
//     this.color = Colors.black,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 50,
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(25),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: .05),
//             blurRadius: 10,
//             spreadRadius: 0,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: TextField(
//         controller: controller,
//         onChanged: onChanged,
//         decoration: InputDecoration(
//           hintText: hintText,
//           hintStyle: TextStyle(color: Colors.grey.shade600),
//           prefixIcon: const Icon(Icons.search, color: Colors.deepOrange),
//           suffixIcon: controller.text.isNotEmpty
//               ? IconButton(
//                   icon: const Icon(Icons.clear, color: Colors.deepOrange),
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

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../widgets/app_scaffold.dart';
import '../../widgets/category_detail_screen.dart';
import '../../widgets/recipe_detail_screen.dart' show RecipeDetailScreen;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final Color primaryColor = Colors.deepOrange;

  // In-memory storage for recent searches
  List<String> _recentSearches = [];
  final List<String> _popularSearches = [
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
  // ignore: unused_field
  bool _showClearButton = false;

  // For filtering
  String _selectedCategory = 'All';
  final List<String> _categories = [
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

  // Fetch trending recipes from MealDB API
  // Since MealDB doesn't have a "trending" endpoint, we'll use random meals
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

    if (isFavorite) {
      _removeFromFavorites(mealId);
    } else {
      _addMealToFavorites(meal);
    }

    setState(() {
      _favoriteMeals[mealId] = !isFavorite;
    });
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe is already in favorites'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Add new recipe to favorites
      existingFavorites.add(recipeMetadata);

      // Save updated favorites metadata
      await favoritesFile.writeAsString(json.encode(existingFavorites));

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${meal['strMeal']} to favorites'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error adding meal to favorites: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to favorites: $e'),
            backgroundColor: Colors.red,
          ),
        );
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

        // Remove this recipe from favorites
        favorites.removeWhere((favorite) => favorite['id'] == mealId);

        // Save updated favorites
        await favoritesFile.writeAsString(json.encode(favorites));

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from favorites'),
              backgroundColor: Colors.grey,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing from favorites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No favorite recipes yet'),
            backgroundColor: Colors.grey,
          ),
        );
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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                        const Text(
                          'Your Favorite Recipes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                          color: Colors.grey[700],
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
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading favorites: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Build a card for favorite recipes
  Widget _buildFavoriteCard(Map<String, dynamic> recipe, String date) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
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
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  recipe['imageUrl'],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image_not_supported,
                          size: 40, color: Colors.grey),
                    );
                  },
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Category and cuisine
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe['category'] ?? 'Main Course',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.public,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe['cuisine'] ?? 'International',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Added date
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Added: $date',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // View button
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.pink,
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
        title: const Text(
          'Search Recipes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search bar
              Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .05),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search for recipes, ingredients...',
                              prefixIcon: Icon(Icons.search),
                              suffixIcon: _showClearButton
                                  ? IconButton(
                                      icon: Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _showClearButton = false;
                                        });
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _showClearButton = value.isNotEmpty;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () =>
                              _performSearch(_searchController.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Search',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),

              // Tab bar
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: primaryColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
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

          // Floating favorite button at bottom left
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'favoritesBtn',
              onPressed: _openFavoritesBottomSheet,
              backgroundColor: Colors.pink,
              child: const Icon(Icons.favorite),
            ),
          ),
        ],
      ),
    );
  }

  // Discover tab content
  Widget _buildDiscoverTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular searches section
          const Text(
            'Popular Searches',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
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
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    search,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Categories section
          const Text(
            'Browse by Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Categories grid with loading state
          _isLoadingCategories
              ? Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                )
              : _categoriesError.isNotEmpty
                  ? Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(_categoriesError),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchCategories,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _mealCategories.length,
                      itemBuilder: (context, index) {
                        final category = _mealCategories[index];
                        return _buildCategoryCard(
                          category['strCategory'],
                          category['strCategoryThumb'],
                          _getCategoryColor(index),
                          category,
                        );
                      },
                    ),

          const SizedBox(height: 32),

          // Trending recipes section
          const Text(
            'Trending Recipes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Trending recipes with loading state
          _isLoadingTrending
              ? Center(
                  child: SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    ),
                  ),
                )
              : _trendingError.isNotEmpty
                  ? Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(_trendingError),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchTrendingRecipes,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      height: 200,
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

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Get a color for a category based on its index
  Color _getCategoryColor(int index) {
    final colors = [
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.pink,
      Colors.purple,
      Colors.amber,
      Colors.teal,
      Colors.indigo,
      Colors.red,
      Colors.brown,
    ];

    return colors[index % colors.length];
  }

  // Category card for browse by category
  Widget _buildCategoryCard(
      String title, String imageUrl, Color color, dynamic category) {
    return InkWell(
      onTap: () {
        // Navigate to category detail screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailScreen(
              category: category,
              cookingTime: '${15 + (category['idCategory'].hashCode % 30)} min',
            ),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: color.withValues(alpha: .2),
                  child: Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 40,
                      color: color.withValues(alpha: .5),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .6),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Trending recipe card
  Widget _buildTrendingRecipeCard(String title, String category, String time,
      String imageUrl, dynamic meal) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, 5),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          width: double.infinity,
                          child: Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Time badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.deepOrange,
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
                  // Favorite button
                  Positioned(
                    top: 8,
                    left: 8,
                    child: InkWell(
                      onTap: () => _toggleFavorite(meal),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _favoriteMeals[meal['idMeal']] ?? false
                              ? Colors.pink
                              : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _favoriteMeals[meal['idMeal']] ?? false
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _favoriteMeals[meal['idMeal']] ?? false
                              ? Colors.white
                              : Colors.red,
                          size: 18,
                        ),
                      ),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
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
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _performSearch(_searchController.text),
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

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: primaryColor.withValues(alpha: .5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No recipes found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different search term or browse categories',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _tabController.animateTo(0); // Switch to discover tab
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Browse Categories'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Filter chips
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: Colors.white,
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
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: primaryColor.withValues(alpha: .2),
                    checkmarkColor: primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? primaryColor : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Results count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                '${filteredResults.length} ${filteredResults.length == 1 ? 'result' : 'results'} found',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort),
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
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: filteredResults.length,
            itemBuilder: (context, index) {
              final meal = filteredResults[index];
              return _buildMealCard(meal);
            },
          ),
        ),
      ],
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
              Icons.history,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No recent searches',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Your search history will appear here',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _tabController.animateTo(0); // Switch to discover tab
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Start Searching'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header with clear button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: _clearRecentSearches,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),

        // Recent searches list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recentSearches.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final search = _recentSearches[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(search),
                trailing: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchController.text = search;
                    _performSearch(search);
                  },
                ),
                onTap: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Meal card for search results
  Widget _buildMealCard(dynamic meal) {
    final mealId = meal['idMeal'];
    final isFavorite = _favoriteMeals[mealId] ?? false;

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
              color: Colors.black.withValues(alpha: .05),
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
                      meal['strMealThumb'],
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
                    // Favorite button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () => _toggleFavorite(meal),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isFavorite ? Colors.pink : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.white : Colors.red,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    // Category badge
                    if (meal['strCategory'] != null)
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
                                Colors.black.withValues(alpha: .7),
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              meal['strCategory'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
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

// Custom search field widget
class CustomSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String) onChanged;
  final VoidCallback onClear;
  final Color backgroundColor;
  final Color textColor;

  const CustomSearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
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
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(color: textColor), // Apply text color here
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
