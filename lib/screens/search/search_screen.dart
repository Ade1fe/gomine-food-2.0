import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../widgets/recipe_detail_screen.dart' show RecipeDetailScreen;



class SearchScreen extends StatefulWidget {
  // ignore: use_super_parameters
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  // App theme colors
  final Color primaryColor = const Color(0xFF2C3E50);
  final Color accentColor = const Color(0xFFFF8C00); // Orange accent color
  final Color backgroundColor = const Color(0xFFF5F7FA);
  final Color cardColor = Colors.white;
  final Color textColor = const Color(0xFF2C3E50);
  final Color secondaryTextColor = const Color(0xFF7F8C8D);

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
  bool _showClearButton = false;

  // For filtering
  String _selectedCategory = 'All';
  final List<String> _filterCategories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
    'Appetizer',
    'Snack'
  ];

  // For favorites
  // ignore: prefer_final_fields
  Map<String, bool> _favoriteMeals = {};

  // For tabs
  late TabController _tabController;

  // For categories and trending recipes
  List<dynamic> _mealCategories = [];
  List<dynamic> _trendingRecipes = [];
  bool _isLoadingCategories = true;
  bool _isLoadingTrending = true;
  String _categoriesError = '';
  String _trendingError = '';

  // For category meals
  List<dynamic> _categoryMeals = [];
  // ignore: unused_field
  bool _isLoadingCategoryMeals = false;
  String _categoryMealsError = '';
  
  // For snackbar
  OverlayEntry? _overlayEntry;
  bool _isSnackbarVisible = false;
  Timer? _snackbarTimer;

  // Category navigation helper
  // late CategoryNavigation _categoryNavigation;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
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
  
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // Initialize category navigation after context is available
  //   _categoryNavigation = CategoryNavigation(
  //     context: context,
  //     accentColor: accentColor,
  //     cardColor: cardColor,
  //     textColor: textColor,
  //     secondaryTextColor: secondaryTextColor,
  //     favoriteMeals: _favoriteMeals,
  //     toggleFavorite: _toggleFavorite,
  //   );
  // }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose();
    _removeSnackBar();
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
        if (mounted) {
          setState(() {
            _mealCategories = data['categories'] ?? [];
            _isLoadingCategories = false;
          });
        }
      } else {
        setState(() {
          _categoriesError = 'Failed to load categories: ${response.statusCode}';
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

  // Fetch trending recipes (random meals for demo)
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

      if (mounted) {
        setState(() {
          _trendingRecipes = trendingMeals;
          _isLoadingTrending = false;
        });
      }
    } catch (e) {
      setState(() {
        _trendingError = 'Error: $e';
        _isLoadingTrending = false;
      });
    }
  }

  // Fetch meals by category
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
        if (mounted) {
          setState(() {
            _categoryMeals = data['meals'] ?? [];
            _isLoadingCategoryMeals = false;
          });
        }
      } else {
        setState(() {
          _categoryMealsError = 'Failed to load meals: ${response.statusCode}';
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

  // Show category details in a modal
  void _showCategoryDetails(String categoryId, String categoryName) {
    // Find the selected category
    final selectedCategory = _mealCategories.firstWhere(
      (category) => category['idCategory'] == categoryId,
      orElse: () => null,
    );
    
    if (selectedCategory == null) return;
    
    // Start loading the meals
    setState(() {
      _isLoadingCategoryMeals = true;
      _categoryMeals = [];
      _categoryMealsError = '';
    });
    
    // Fetch meals for this category
    _fetchMealsByCategory(categoryName).then((_) {
      if (!mounted) return;
      
      if (_categoryMeals.isNotEmpty && _categoryMealsError.isEmpty) {
        // Show the modal with the fetched meals
        _showCategoryModal(categoryId, categoryName, selectedCategory);
      } else if (_categoryMealsError.isNotEmpty) {
        _showSnackBar('Error: $_categoryMealsError', SnackBarType.error);
      } else {
        _showSnackBar('No recipes found for this category', SnackBarType.info);
      }
    });
  }

  // Show category modal with meals
  void _showCategoryModal(String categoryId, String categoryName, dynamic selectedCategory) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => DraggableScrollableSheet(
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
                        color: accentColor,
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
                      onPressed: () => Navigator.of(modalContext).pop(),
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
              
              // Meals grid
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
                    return _buildMealCard(meal, modalContext);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build a meal card for the category view
  Widget _buildMealCard(dynamic meal, BuildContext modalContext) {
    final mealId = meal['idMeal'];
    final isFavorite = _favoriteMeals[mealId] ?? false;
    
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withValues(alpha:.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Close the modal first using the correct context
          Navigator.of(modalContext).pop();
          
          // Then navigate to recipe detail
          if (mounted) {
            _navigateToRecipeDetail(meal);
          }
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
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () {
                        _toggleFavorite(meal);
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
                              // ignore: deprecated_member_use
                              color: Colors.black.withValues(alpha:.1),
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
                          meal['strCategory'] ?? '',
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

  // Navigate to recipe detail screen
  void _navigateToRecipeDetail(dynamic meal) {
    // Use Navigator.of(context).push to ensure proper context
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(
          mealId: meal['idMeal'],
          mealName: meal['strMeal'],
          mealImage: meal['strMealThumb'],
        ),
      ),
    ).then((_) {
      // This will run when returning from the detail screen
      if (mounted) {
        setState(() {
          // Refresh any necessary data here
        });
      }
    });
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

  // Load favorites from storage
  Future<void> _loadFavorites() async {
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
      debugPrint('Error loading favorites: $e');
    }
  }

  // Toggle favorite status
  void _toggleFavorite(dynamic meal) {
    final mealId = meal['idMeal'];
    final isFavorite = _favoriteMeals[mealId] ?? false;

    // Update the state immediately
    setState(() {
      _favoriteMeals[mealId] = !isFavorite;
    });

    // Then handle the database operations
    if (isFavorite) {
      _removeFromFavorites(mealId);
    } else {
      _addToFavorites(meal);
    }
  }

  // Add meal to favorites
  Future<void> _addToFavorites(dynamic meal) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final favoritesFile = File('${directory.path}/favorite_recipes.json');

      // Create recipe metadata
      final Map<String, dynamic> recipeMetadata = {
        'id': meal['idMeal'],
        'name': meal['strMeal'],
        'imageUrl': meal['strMealThumb'],
        'date': DateTime.now().toIso8601String(),
        'category': meal['strCategory'] ?? 'Main Course',
        'cuisine': meal['strArea'] ?? 'International',
      };

      // Load existing favorites metadata
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
        _showSnackBar('Recipe is already in your favorites', SnackBarType.warning);
        return;
      }

      // Add new recipe to favorites
      existingFavorites.add(recipeMetadata);

      // Save updated favorites metadata
      await favoritesFile.writeAsString(json.encode(existingFavorites));

      // Show success message
      if (mounted) {
        _showSnackBar('Added "${meal['strMeal']}" to favorites', SnackBarType.success);
      }
    } catch (e) {
      debugPrint('Error adding to favorites: $e');
      if (mounted) {
        _showSnackBar('Failed to add to favorites', SnackBarType.error);
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
          _showSnackBar('Removed "$recipeName" from favorites', SnackBarType.info);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error removing from favorites', SnackBarType.error);
      }
    }
  }

  // Show favorites bottom sheet
  void _showFavoritesBottomSheet() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final favoritesFile = File('${directory.path}/favorite_recipes.json');

      List<Map<String, dynamic>> favoriteRecipes = [];
      if (await favoritesFile.exists()) {
        final content = await favoritesFile.readAsString();
        favoriteRecipes = List<Map<String, dynamic>>.from(json.decode(content));
      }

      if (favoriteRecipes.isEmpty) {
        _showSnackBar('No favorite recipes yet', SnackBarType.info);
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
      _showSnackBar('Error loading favorites', SnackBarType.error);
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
          // First close the bottom sheet
          Navigator.of(context).pop();
          
          // Then navigate to recipe detail
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
                  // ignore: deprecated_member_use
                  color: accentColor.withValues(alpha:.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: accentColor,
                  ),
                  onPressed: () {
                    // First close the bottom sheet
                    Navigator.of(context).pop();
                    
                    // Then navigate to recipe detail
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

  // Remove any existing snackbar
  void _removeSnackBar() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isSnackbarVisible = false;
    _snackbarTimer?.cancel();
  }

  // Show custom snackbar
  void _showSnackBar(String message, SnackBarType type) {
    // If there's already a snackbar showing, remove it first
    if (_isSnackbarVisible) {
      _removeSnackBar();
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
      // ignore: unreachable_switch_default
      default:
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
                    // ignore: deprecated_member_use
                    color: Colors.black.withValues(alpha:.1),
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
                    icon: Icon(Icons.close, color: textColor.withValues(alpha: .8), size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: _removeSnackBar,
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
      _removeSnackBar();
    });
  }

  // Perform search
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Save to recent searches
      _saveSearch(query);

      // API call to search for meals
      final response = await http.get(
        Uri.parse(
            'https://www.themealdb.com/api/json/v1/1/search.php?s=${query.trim()}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _searchResults = data['meals'] ?? [];
            _isLoading = false;

            // Switch to results tab if we have results
            if (_searchResults.isNotEmpty) {
              _tabController.animateTo(1); // Results tab
            } else {
              _showSnackBar('No recipes found for "$query"', SnackBarType.info);
            }
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load search results: ${response.statusCode}';
          _isLoading = false;
          _showSnackBar(_errorMessage, SnackBarType.error);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
        _showSnackBar(_errorMessage, SnackBarType.error);
      });
    }
  }

  // Get a color for a category based on its index
  Color _getCategoryColor(int index) {
    final colors = [
      accentColor, // Orange accent (primary)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
          automaticallyImplyLeading: false, // Add this line to remove the back arrow
        elevation: 0,
        // leading: IconButton(
        //   icon: Icon(
        //     Icons.arrow_back,
        //     color: textColor,
        //   ),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
        title: Text(
          'Culinary Explorer',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.favorite,
              color: const Color(0xFFE74C3C),
            ),
            onPressed: _showFavoritesBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: cardColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search input
                Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Icon(
                          Icons.search,
                          color: secondaryTextColor,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Search for recipes, ingredients...',
                            hintStyle: TextStyle(color: secondaryTextColor),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                          ),
                          style: TextStyle(color: textColor),
                          onSubmitted: (value) => _performSearch(value),
                        ),
                      ),
                      if (_showClearButton)
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: secondaryTextColor,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _showClearButton = false;
                            });
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Search button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _performSearch(_searchController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Search',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            color: cardColor,
            child: TabBar(
              controller: _tabController,
              labelColor: accentColor,
              unselectedLabelColor: secondaryTextColor,
              indicatorColor: accentColor,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'DISCOVER'),
                Tab(text: 'RESULTS'),
                Tab(text: 'RECENT'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // DISCOVER TAB
                _buildDiscoverTab(),
                
                // RESULTS TAB
                _buildResultsTab(),
                
                // RECENT TAB
                _buildRecentTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build the Discover tab content
  Widget _buildDiscoverTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Popular Searches
        _buildSectionHeader(Icons.trending_up, 'Popular Searches'),
        const SizedBox(height: 8),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  search,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: 24),
        
        // Categories
        _buildSectionHeader(Icons.category, 'Browse by Category'),
        const SizedBox(height: 12),
        
        // Show loading indicator or error if needed
        if (_isLoadingCategories)
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          )
        else if (_categoriesError.isNotEmpty)
          Center(
            child: Text(
              _categoriesError,
              style: TextStyle(color: Colors.red[400]),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _mealCategories.length,
            itemBuilder: (context, index) {
              final category = _mealCategories[index];
              return InkWell(
                onTap: () => _showCategoryDetails(
                  category['idCategory'],
                  category['strCategory'],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Category image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: category['strCategoryThumb'],
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
                            color: _getCategoryColor(index).withValues(alpha:.2),
                            child: Center(
                              child: Icon(
                                Icons.category,
                                size: 40,
                                color: _getCategoryColor(index),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha:.7),
                            ],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                      // Category name
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category['strCategory'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.chevron_right,
                                  size: 16,
                                  color: accentColor,
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
            },
          ),
          
        const SizedBox(height: 24),
        
        // Trending Recipes
        _buildSectionHeader(Icons.local_fire_department, 'Trending Recipes'),
        const SizedBox(height: 12),
        
        // Show loading indicator or error if needed
        if (_isLoadingTrending)
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          )
        else if (_trendingError.isNotEmpty)
          Center(
            child: Text(
              _trendingError,
              style: TextStyle(color: Colors.red[400]),
            ),
          )
        else
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _trendingRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _trendingRecipes[index];
                final isFavorite = _favoriteMeals[recipe['idMeal']] ?? false;
                
                return Container(
                  width: 180,
                  margin: EdgeInsets.only(
                    right: index == _trendingRecipes.length - 1 ? 0 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _navigateToRecipeDetail(recipe),
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recipe image
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: recipe['strMealThumb'],
                                width: double.infinity,
                                height: 120,
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
                                  height: 120,
                                  child: Center(
                                    child: Icon(
                                      Icons.restaurant,
                                      size: 40,
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Favorite button
                            Positioned(
                              top: 8,
                              right: 8,
                              child: InkWell(
                                onTap: () => _toggleFavorite(recipe),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isFavorite
                                        ? const Color(0xFFE74C3C)
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha:.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite
                                        ? Colors.white
                                        : const Color(0xFFE74C3C),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            // Time badge (if available)
                            if (recipe['strCategory'] != null)
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
                                        color: Colors.black.withValues(alpha:.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    recipe['strCategory'],
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        // Recipe info
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe['strMeal'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: textColor,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.public,
                                    size: 14,
                                    color: secondaryTextColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    recipe['strArea'] ?? 'International',
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
              },
            ),
          ),
      ],
    );
  }

  // Build the Results tab content
  Widget _buildResultsTab() {
    return Column(
      children: [
        // Filter categories
        Container(
          color: cardColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _filterCategories.map((category) {
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? accentColor.withValues(alpha:.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? accentColor : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? accentColor : secondaryTextColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        
        // Results count and sort
        Container(
          color: cardColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_searchResults.length} recipes found',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 14,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  // Sort functionality would go here
                },
                icon: Icon(
                  Icons.sort,
                  size: 18,
                  color: secondaryTextColor,
                ),
                label: Text(
                  'Sort',
                  style: TextStyle(
                    color: secondaryTextColor,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Results list
        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                )
              : _errorMessage.isNotEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.red[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _searchResults.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 48,
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
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try searching for something else',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final recipe = _searchResults[index];
                            
                            // Filter by category if not "All"
                            if (_selectedCategory != 'All' &&
                                recipe['strCategory'] != _selectedCategory) {
                              return const SizedBox.shrink();
                            }
                            
                            return _buildMealCard(recipe, context);
                          },
                        ),
        ),
      ],
    );
  }

  // Build the Recent tab content
  Widget _buildRecentTab() {
    return Column(
      children: [
        // Header with clear button
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: textColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              if (_recentSearches.isNotEmpty)
                TextButton(
                  onPressed: _clearRecentSearches,
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Recent searches list or empty state
        Expanded(
          child: _recentSearches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No recent searches',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your search history will appear here',
                        style: TextStyle(
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _recentSearches.length,
                  itemBuilder: (context, index) {
                    final search = _recentSearches[index];
                    return Card(
                      margin: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 8,
                        top: index == 0 ? 0 : 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha:.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.history,
                            color: accentColor,
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
                          icon: Icon(
                            Icons.search,
                            color: accentColor,
                          ),
                          onPressed: () {
                            _searchController.text = search;
                            _performSearch(search);
                          },
                        ),
                        onTap: () {
                          _searchController.text = search;
                          _performSearch(search);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Build a section header with icon and title
  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: textColor,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
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