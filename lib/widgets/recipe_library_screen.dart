import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

import 'app_scaffold.dart';

class RecipeLibraryScreen extends StatefulWidget {
  const RecipeLibraryScreen({super.key});

  @override
  State<RecipeLibraryScreen> createState() => _RecipeLibraryScreenState();
}

class _RecipeLibraryScreenState extends State<RecipeLibraryScreen> {
  List<Map<String, dynamic>> _recipes = [];
  List<Map<String, dynamic>> _favoriteRecipes = [];
  List<Map<String, dynamic>> _filteredRecipes = []; 
  bool _isLoading = true;
  bool _showOnlyFavorites = false; // Toggle for favorites filter
  // Map to track favorite status of recipes
  Map<String, bool> _favoriteStatus = {};

  @override
  void initState() {
    super.initState();
    _loadRecipes();
    _loadFavorites();
  }

  // Load favorite recipes to initialize the favorite status map
  Future<void> _loadFavorites() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final favoritesFile = File('${directory.path}/favorite_recipes.json');

      if (await favoritesFile.exists()) {
        final content = await favoritesFile.readAsString();
        final List<dynamic> favorites = json.decode(content);

        // Store the favorite recipes
        _favoriteRecipes = List<Map<String, dynamic>>.from(favorites);

        setState(() {
          // Initialize favorite status map with null check
          for (var favorite in favorites) {
            if (favorite['id'] != null &&
                favorite['id'].toString().isNotEmpty) {
              _favoriteStatus[favorite['id'].toString()] = true;
            }
          }

          // Update filtered recipes if showing only favorites
          if (_showOnlyFavorites) {
            _updateFilteredRecipes();
          }
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load favorites: $e');
    }
  }

  // Update filtered recipes based on current filter settings
  void _updateFilteredRecipes() {
    if (_showOnlyFavorites) {
      _filteredRecipes = _recipes.where((recipe) {
        String recipeId = recipe['id']?.toString() ?? recipe['fileName'] ?? '';
        return _favoriteStatus[recipeId] == true;
      }).toList();
    } else {
      _filteredRecipes = List.from(_recipes);
    }
  }

  // Toggle favorites filter
  void _toggleFavoritesFilter() {
    setState(() {
      _showOnlyFavorites = !_showOnlyFavorites;
      _updateFilteredRecipes();
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_showOnlyFavorites
            ? 'Showing only favorite recipes'
            : 'Showing all recipes'),
        duration: const Duration(seconds: 2),
        backgroundColor:
            _showOnlyFavorites ? Colors.pink : Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final directory = await getApplicationDocumentsDirectory();
      final metadataFile = File('${directory.path}/recipe_library.json');

      if (await metadataFile.exists()) {
        final content = await metadataFile.readAsString();
        final List<dynamic> decoded = json.decode(content);

        setState(() {
          _recipes = List<Map<String, dynamic>>.from(decoded);
          _recipes.sort((a, b) =>
              DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

          // Update filtered recipes
          _updateFilteredRecipes();

          _isLoading = false;
        });
      } else {
        setState(() {
          _recipes = [];
          _filteredRecipes = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load recipes: $e');
      setState(() {
        _recipes = [];
        _filteredRecipes = [];
        _isLoading = false;
      });
    }
  }

  // Toggle favorite status for a recipe
  Future<void> _toggleFavorite(Map<String, dynamic> recipe) async {
    // Ensure recipe has an id
    if (recipe['id'] == null) {
      // If no id exists, we can use the filename as a unique identifier
      recipe['id'] = recipe['fileName'] ?? DateTime.now().toIso8601String();
    }

    final String recipeId = recipe['id'].toString();
    final bool currentStatus = _favoriteStatus[recipeId] ?? false;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final favoritesFile = File('${directory.path}/favorite_recipes.json');

      List<Map<String, dynamic>> favorites = [];
      if (await favoritesFile.exists()) {
        final content = await favoritesFile.readAsString();
        favorites = List<Map<String, dynamic>>.from(json.decode(content));
      }

      if (currentStatus) {
        // Remove from favorites
        favorites.removeWhere((favorite) =>
            favorite['id'] != null && favorite['id'].toString() == recipeId);
      } else {
        // Add to favorites
        // Check if already exists
        if (!favorites.any((favorite) =>
            favorite['id'] != null && favorite['id'].toString() == recipeId)) {
          favorites.add(recipe);
        }
      }

      // Save updated favorites
      await favoritesFile.writeAsString(json.encode(favorites));

      // Update favorites list
      _favoriteRecipes = favorites;

      // Update UI
      setState(() {
        _favoriteStatus[recipeId] = !currentStatus;

        // Update filtered recipes if showing only favorites
        if (_showOnlyFavorites) {
          _updateFilteredRecipes();
        }
      });

      // Show animation/feedback
      _showFavoriteAnimation(!currentStatus);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update favorites: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Delete all favorites
  Future<void> _deleteAllFavorites() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Favorites'),
          content: const Text(
              'Are you sure you want to remove all recipes from your favorites? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  // Get app directory
                  final directory = await getApplicationDocumentsDirectory();
                  final favoritesFile =
                      File('${directory.path}/favorite_recipes.json');

                  // Clear favorites file
                  await favoritesFile.writeAsString(json.encode([]));

                  // Update UI
                  setState(() {
                    _favoriteStatus = {}; // Clear all favorites
                    _favoriteRecipes = []; // Clear favorites list

                    // Update filtered recipes if showing only favorites
                    if (_showOnlyFavorites) {
                      _updateFilteredRecipes();
                    }
                  });

                  // Show feedback
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All favorites removed'),
                      backgroundColor: Colors.grey,
                    ),
                  );
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to clear favorites: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child:
                  const Text('Delete All', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Show a heart animation when adding/removing from favorites
  void _showFavoriteAnimation(bool adding) {
    ScaffoldMessenger.of(context).clearSnackBars();

    final Color bgColor = adding ? Colors.pink : Colors.grey.shade800;
    final String message =
        adding ? 'Added to favorites' : 'Removed from favorites';
    final IconData icon = adding ? Icons.favorite : Icons.favorite_border;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.5, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        backgroundColor: bgColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: adding
            ? SnackBarAction(
                label: 'VIEW',
                textColor: Colors.white,
                onPressed: () {
                  _showFavoritesBottomSheet();
                },
              )
            : null,
      ),
    );
  }

  // Show bottom sheet with all favorite recipes
  void _showFavoritesBottomSheet() {
    if (_favoriteRecipes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No favorite recipes yet'),
          backgroundColor: Colors.grey,
        ),
      );
      return;
    }

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text(
                            'Your Favorite Recipes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${_favoriteRecipes.length} recipes',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    if (_favoriteRecipes.isNotEmpty)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _deleteAllFavorites();
                          },
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Clear All'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Favorited recipes list
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: _favoriteRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _favoriteRecipes[index];
                    final date = DateTime.parse(
                        recipe['date'] ?? DateTime.now().toIso8601String());
                    final now = DateTime.now();

                    String formattedDate;
                    if (now.difference(date).inDays == 0) {
                      formattedDate = 'Today';
                    } else if (now.difference(date).inDays == 1) {
                      formattedDate = 'Yesterday';
                    } else {
                      formattedDate = '${date.day}/${date.month}/${date.year}';
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
          _openRecipe(recipe['fileName']);
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                  ],
                ),
              ),
              // Remove from favorites button
              IconButton(
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.pink,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _toggleFavorite(recipe);
                },
                tooltip: 'Remove from favorites',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openRecipe(String fileName) async {
    try {
      Directory? directory;

      if (Platform.isAndroid) {
        // Try Downloads directory first
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final filePath = '${directory!.path}/$fileName';
      final file = File(filePath);

      if (await file.exists()) {
        await OpenFile.open(filePath);
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe file not found'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open recipe: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteRecipe(int index) async {
    try {
      final recipe = _filteredRecipes[index];

      // Remove from UI first
      setState(() {
        _recipes.removeWhere((r) => r['fileName'] == recipe['fileName']);
        _filteredRecipes.removeAt(index);
      });

      // Try to delete the file
      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final file = File('${directory!.path}/${recipe['fileName']}');
      if (await file.exists()) {
        await file.delete();
      }

      // Update metadata file
      final appDir = await getApplicationDocumentsDirectory();
      final metadataFile = File('${appDir.path}/recipe_library.json');
      await metadataFile.writeAsString(json.encode(_recipes));

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // If error, reload the list
      _loadRecipes();

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete recipe: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Add confirmation dialog before deleting
  Future<void> _confirmDeleteRecipe(int index) async {
    final recipe = _filteredRecipes[index];

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Recipe'),
          content: Text('Are you sure you want to delete "${recipe['name']}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteRecipe(index);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Add function to delete all recipes
  Future<void> _deleteAllRecipes() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete All Recipes'),
          content: const Text(
              'Are you sure you want to delete all recipes? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  // Get directories
                  Directory? directory;
                  if (Platform.isAndroid) {
                    directory = Directory('/storage/emulated/0/Download');
                    if (!await directory.exists()) {
                      directory = await getExternalStorageDirectory();
                    }
                  } else {
                    directory = await getApplicationDocumentsDirectory();
                  }

                  // Delete all recipe files
                  for (var recipe in _recipes) {
                    final file =
                        File('${directory!.path}/${recipe['fileName']}');
                    if (await file.exists()) {
                      await file.delete();
                    }
                  }

                  // Clear metadata
                  final appDir = await getApplicationDocumentsDirectory();
                  final metadataFile =
                      File('${appDir.path}/recipe_library.json');
                  await metadataFile.writeAsString(json.encode([]));

                  // Update UI
                  setState(() {
                    _recipes = [];
                    _filteredRecipes = [];
                  });

                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All recipes deleted'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete recipes: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  _loadRecipes();
                }
              },
              child:
                  const Text('Delete All', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.deepOrange;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('My Recipe Library'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Add favorites filter toggle
          IconButton(
            icon: Icon(
              _showOnlyFavorites ? Icons.filter_list_off : Icons.filter_list,
              color: _showOnlyFavorites ? Colors.pink : Colors.white,
            ),
            onPressed: _toggleFavoritesFilter,
            tooltip:
                _showOnlyFavorites ? 'Show all recipes' : 'Show only favorites',
          ),
          // Add favorites button
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.favorite),
                onPressed: _showFavoritesBottomSheet,
                tooltip: 'View Favorites',
              ),
              if (_favoriteRecipes.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _favoriteRecipes.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Add delete all button if recipes exist
          if (_recipes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _deleteAllRecipes,
              tooltip: 'Delete All Recipes',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecipes,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : _filteredRecipes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _showOnlyFavorites ? Icons.favorite_border : Icons.book,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _showOnlyFavorites
                            ? 'No favorite recipes yet'
                            : 'No recipes saved yet',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _showOnlyFavorites
                            ? 'Add recipes to your favorites to see them here'
                            : 'Download recipes to view them here',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      if (_showOnlyFavorites && _recipes.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: ElevatedButton.icon(
                            onPressed: _toggleFavoritesFilter,
                            icon: const Icon(Icons.filter_list_off),
                            label: const Text('Show All Recipes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Show filter indicator if filtering by favorites
                    if (_showOnlyFavorites)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.pink.shade50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.favorite,
                              size: 16,
                              color: Colors.pink,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Showing favorite recipes only',
                              style: TextStyle(
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: _toggleFavoritesFilter,
                              child: const Text(
                                'Show All',
                                style: TextStyle(
                                  color: Colors.pink,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(1),
                        itemCount: _filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _filteredRecipes[index];
                          final date = DateTime.parse(recipe['date']);
                          final formattedDate =
                              '${date.day}/${date.month}/${date.year}';

                          // Ensure recipe has an id for favorite tracking
                          String recipeId = recipe['id']?.toString() ??
                              recipe['fileName'] ??
                              '';

                          // Get favorite status for this recipe
                          final bool isFavorite =
                              _favoriteStatus[recipeId] ?? false;

                          return Dismissible(
                            key: Key(recipe['fileName']),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            direction: DismissDirection.endToStart,
                            confirmDismiss: (direction) async {
                              // Show confirmation dialog before dismissing
                              await _confirmDeleteRecipe(index);
                              return false; // Don't dismiss automatically, we'll handle it in _deleteRecipe
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () => _openRecipe(recipe['fileName']),
                                borderRadius: BorderRadius.circular(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                          child: Image.network(
                                            recipe['imageUrl'],
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                height: 150,
                                                color: Colors.grey[300],
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.image_not_supported,
                                                    size: 50,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        // Add favorite button overlay
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: Icon(
                                                isFavorite
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: isFavorite
                                                    ? Colors.pink
                                                    : Colors.white,
                                              ),
                                              onPressed: () =>
                                                  _toggleFavorite(recipe),
                                              tooltip: isFavorite
                                                  ? 'Remove from favorites'
                                                  : 'Add to favorites',
                                              iconSize: 24,
                                              padding: const EdgeInsets.all(8),
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  recipe['name'],
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (isFavorite)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.pink.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.favorite,
                                                        size: 12,
                                                        color: Colors.pink,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      const Text(
                                                        'Favorite',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.pink,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.category,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                recipe['category'] ??
                                                    'Main Course',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Icon(
                                                Icons.public,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                recipe['cuisine'] ??
                                                    'International',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Downloaded: $formattedDate',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  // Add explicit delete button
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        size: 20),
                                                    color: Colors.red,
                                                    onPressed: () =>
                                                        _confirmDeleteRecipe(
                                                            index),
                                                    tooltip: 'Delete Recipe',
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  ElevatedButton.icon(
                                                    onPressed: () =>
                                                        _openRecipe(
                                                            recipe['fileName']),
                                                    icon: const Icon(
                                                        Icons.visibility,
                                                        size: 16),
                                                    label: const Text('View'),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          primaryColor,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 12,
                                                        vertical: 8,
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      // Add a floating action button to view favorites
      floatingActionButton: FloatingActionButton(
        onPressed: _showFavoritesBottomSheet,
        backgroundColor: Colors.pink,
        child: const Icon(Icons.favorite),
        tooltip: 'View Favorites',
      ),
    );
  }
}
