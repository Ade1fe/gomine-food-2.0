import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/download_service.dart';
import '../widgets/app_scaffold.dart';
import 'recipe_library_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String mealId;
  final String mealName;
  final String mealImage;

  const RecipeDetailScreen({
    super.key,
    required this.mealId,
    required this.mealName,
    required this.mealImage,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  Map<String, dynamic> recipeDetails = {};
  List<String> ingredients = [];
  List<String> measures = [];
  String errorMessage = '';
  bool isFavorite = false;
  int _selectedTabIndex = 0;
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchRecipeDetails();
    _checkIfFavorite(); // Check if recipe is already in favorites

    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showTitle) {
        setState(() {
          _showTitle = true;
        });
      } else if (_scrollController.offset <= 200 && _showTitle) {
        setState(() {
          _showTitle = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Check if recipe is already in favorites
  Future<void> _checkIfFavorite() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final favoritesFile = File('${directory.path}/favorite_recipes.json');

      if (await favoritesFile.exists()) {
        final content = await favoritesFile.readAsString();
        final List<dynamic> favorites = json.decode(content);

        // Check if this recipe is in favorites
        final bool isInFavorites =
            favorites.any((favorite) => favorite['id'] == widget.mealId);

        setState(() {
          isFavorite = isInFavorites;
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _fetchRecipeDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://www.themealdb.com/api/json/v1/1/lookup.php?i=${widget.mealId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          final meal = data['meals'][0];

          // Extract ingredients and measures
          List<String> extractedIngredients = [];
          List<String> extractedMeasures = [];

          for (int i = 1; i <= 20; i++) {
            final ingredient = meal['strIngredient$i'];
            final measure = meal['strMeasure$i'];

            if (ingredient != null && ingredient.trim().isNotEmpty) {
              extractedIngredients.add(ingredient);
              extractedMeasures.add(measure ?? '');
            }
          }

          setState(() {
            recipeDetails = meal;
            ingredients = extractedIngredients;
            measures = extractedMeasures;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Recipe details not found';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load recipe details';
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

  // Toggle favorite status
  Future<void> _toggleFavorite() async {
    try {
      if (isFavorite) {
        // Remove from favorites
        await _removeFromFavorites();
        setState(() {
          isFavorite = false;
        });

        // Show remove animation
        _showFavoriteAnimation(false);
      } else {
        // Add to favorites with animated dialog
        _showAddToFavoritesDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Show animated dialog when adding to favorites
  void _showAddToFavoritesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .1),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.favorite,
                  color: Colors.pink,
                  size: 70,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Adding to Favorites',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.mealName,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Add to favorites after showing dialog
    _addToFavorites().then((_) {
      if (mounted) {
        // Close dialog
        Navigator.of(context).pop();

        // Update UI state
        setState(() {
          isFavorite = true;
        });

        // Show success animation
        _showFavoriteAnimation(true);
      }
    }).catchError((error) {
      if (mounted) {
        // Close dialog
        Navigator.of(context).pop();

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecipeLibraryScreen(),
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }

  // Open favorites bottom sheet to view saved recipes
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
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RecipeLibraryScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.library_books),
                          label: const Text('Library'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.pink,
                          ),
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
    final currentMeal = recipe['id'] == widget.mealId;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: currentMeal
            ? BorderSide(color: Colors.pink.shade300, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).pop();
          if (!currentMeal) {
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
          }
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
                        if (currentMeal)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.pink.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Current',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.pink,
                                fontWeight: FontWeight.bold,
                              ),
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
                  if (!currentMeal) {
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
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add recipe to favorites
  Future<void> _addToFavorites() async {
    try {
      // Create recipe metadata
      final Map<String, dynamic> recipeMetadata = {
        'id': widget.mealId,
        'name': widget.mealName,
        'fileName': 'recipe_${widget.mealId}.pdf',
        'imageUrl': widget.mealImage,
        'date': DateTime.now().toIso8601String(),
        'category': recipeDetails['strCategory'] ?? 'Main Course',
        'cuisine': recipeDetails['strArea'] ?? 'International',
      };

      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();

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
          existingFavorites.any((favorite) => favorite['id'] == widget.mealId);

      if (recipeExists) {
        // Recipe already exists, no need to add it again
        return;
      }

      // Add new recipe to favorites
      existingFavorites.add(recipeMetadata);

      // Save updated favorites metadata
      await favoritesFile.writeAsString(json.encode(existingFavorites));
    } catch (e) {
      rethrow; // Rethrow to be caught by _toggleFavorite
    }
  }

  // Remove recipe from favorites
  Future<void> _removeFromFavorites() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final favoritesFile = File('${directory.path}/favorite_recipes.json');

      if (await favoritesFile.exists()) {
        final content = await favoritesFile.readAsString();
        List<Map<String, dynamic>> favorites =
            List<Map<String, dynamic>>.from(json.decode(content));

        // Remove this recipe from favorites
        favorites.removeWhere((favorite) => favorite['id'] == widget.mealId);

        // Save updated favorites
        await favoritesFile.writeAsString(json.encode(favorites));
      }
    } catch (e) {
      rethrow; // Rethrow to be caught by _toggleFavorite
    }
  }

  Future<void> _downloadRecipe() async {
    try {
      // Check if the recipe is already downloaded
      final bool isAlreadyDownloaded =
          await DownloadService().isRecipeDownloaded(
        widget.mealId,
        widget.mealName,
      );

      if (isAlreadyDownloaded) {
        // Show a dialog asking if the user wants to download again
        final bool shouldDownload = await showDialog(
              // ignore: use_build_context_synchronously
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Recipe Already Downloaded'),
                content: const Text(
                    'This recipe is already in your library. Do you want to download it again?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Yes'),
                  ),
                ],
              ),
            ) ??
            false;

        if (!shouldDownload) {
          // User chose not to download again, navigate to library instead
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RecipeLibraryScreen(),
              ),
            );
          }
          return;
        }
      }

      // Show loading indicator
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preparing recipe for download...'),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.deepOrange,
        ),
      );

      // Fetch image from network and convert to bytes
      Uint8List? imageBytes;
      try {
        final response = await http.get(Uri.parse(widget.mealImage));
        if (response.statusCode == 200) {
          imageBytes = response.bodyBytes;
        }
      } catch (e) {
        debugPrint('Failed to load image: $e');
      }

      // Create PDF document
      final pdf = pw.Document();

      // Create image provider if image was successfully loaded
      final pw.MemoryImage? image =
          imageBytes != null ? pw.MemoryImage(imageBytes) : null;

      // Parse instructions into steps
      final instructions = recipeDetails['strInstructions'] ?? '';
      List<String> instructionSteps = [];

      // First try to split by line breaks
      final lineBreakSteps = instructions
          .split(RegExp(r'\r\n|\r|\n'))
          .where((String step) => step.trim().isNotEmpty)
          .toList();

      // If we have multiple steps from line breaks, use those
      if (lineBreakSteps.length > 1) {
        instructionSteps = lineBreakSteps;
      } else {
        // Otherwise try to split by numbered steps (e.g., "1. Step one", "2. Step two")
        final numberedSteps =
            RegExp(r'(?:\d+\.\s*)([^\d].*?)(?=\d+\.\s*|$)', dotAll: true)
                .allMatches(instructions)
                .map((match) => match.group(1)?.trim() ?? '')
                .where((String step) => step.isNotEmpty)
                .toList();

        if (numberedSteps.isNotEmpty) {
          instructionSteps = numberedSteps;
        } else {
          // If no clear steps, split by sentences
          instructionSteps = instructions
              .split(RegExp(r'(?<=[.!?])\s+'))
              .where((String step) => step.trim().isNotEmpty)
              .toList();

          // If still no clear steps, use the whole text
          if (instructionSteps.length <= 1) {
            instructionSteps = [instructions];
          }
        }
      }

      // Add cover page with recipe title and image
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              // Wrap with pw.Center to center everything on the page
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    widget.mealName,
                    style: pw.TextStyle(
                        fontSize: 28, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 20),

                  // Add image if available
                  if (image != null)
                    pw.Container(
                      width: 300,
                      height: 200,
                      decoration: pw.BoxDecoration(
                        image: pw.DecorationImage(
                          image: image,
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    ),

                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Category: ${recipeDetails['strCategory'] ?? 'Main Course'}',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.Text(
                    'Cuisine: ${recipeDetails['strArea'] ?? 'International'}',
                    style: const pw.TextStyle(fontSize: 14),
                  ),

                  pw.SizedBox(height: 40),
                  pw.Text(
                    'Recipe Details',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Add ingredients page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Ingredients',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 15),

                // List ingredients with numbers
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: List.generate(
                    ingredients.length,
                    (index) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            width: 24,
                            height: 24,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.deepOrange,
                              shape: pw.BoxShape.circle,
                            ),
                            alignment: pw.Alignment.center,
                            child: pw.Text(
                              '${index + 1}',
                              style: pw.TextStyle(
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 10),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  ingredients[index],
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  measures[index],
                                  style: const pw.TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Add instructions page(s)
      // Split instructions into multiple pages if needed
      const int stepsPerPage = 5;
      for (int i = 0; i < instructionSteps.length; i += stepsPerPage) {
        final endIdx = (i + stepsPerPage < instructionSteps.length)
            ? i + stepsPerPage
            : instructionSteps.length;

        final currentPageSteps = instructionSteps.sublist(i, endIdx);

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Cooking Instructions',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 15),

                  // List instructions with numbers
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: List.generate(
                      currentPageSteps.length,
                      (index) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 15),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              width: 24,
                              height: 24,
                              decoration: pw.BoxDecoration(
                                color: PdfColors.deepOrange,
                                shape: pw.BoxShape.circle,
                              ),
                              alignment: pw.Alignment.center,
                              child: pw.Text(
                                '${i + index + 1}',
                                style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            pw.SizedBox(width: 10),
                            pw.Expanded(
                              child: pw.Text(
                                currentPageSteps[index],
                                style: const pw.TextStyle(
                                  fontSize: 12,
                                  lineSpacing: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }

      // Increment the download count
      DownloadService().incrementDownloadCount();

      // Get the appropriate directory based on platform
      Directory? directory;

      if (Platform.isAndroid) {
        // For Android, request storage permission and use the Downloads directory
        if (await Permission.storage.request().isGranted) {
          try {
            // Try to use the Downloads directory for Android 10 and below
            directory = Directory('/storage/emulated/0/Download');
            if (!await directory.exists()) {
              // Fallback to external storage directory
              final externalDir = await getExternalStorageDirectory();
              if (externalDir != null) {
                directory = externalDir;
              } else {
                // If external storage is not available, use app documents directory
                directory = await getApplicationDocumentsDirectory();
              }
            }
          } catch (e) {
            // Fallback to app documents directory
            directory = await getApplicationDocumentsDirectory();
          }
        } else {
          // If permission is denied, use app documents directory
          directory = await getApplicationDocumentsDirectory();
        }
      } else {
        // For iOS and other platforms
        directory = await getApplicationDocumentsDirectory();
      }

      // Create a sanitized filename
      final fileName =
          '${widget.mealName.replaceAll(RegExp(r'[^\w\s]+'), '').replaceAll(' ', '_')}_recipe.pdf';
      final file = File('${directory.path}/$fileName');

      // Save the PDF
      await file.writeAsBytes(await pdf.save());

      // Save metadata for the recipe library
      await _saveRecipeMetadata(fileName, widget.mealName, widget.mealImage);

      // Show success message with file path
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Recipe saved to ${Platform.isAndroid ? 'Downloads folder' : 'Documents folder'}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () {
                try {
                  OpenFile.open(file.path);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cannot open file: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save recipe: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Save recipe metadata for the recipe library
  Future<void> _saveRecipeMetadata(
      String fileName, String recipeName, String imageUrl) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final metadataFile = File('${directory.path}/recipe_library.json');

      // Create a list to store recipe metadata
      List<Map<String, dynamic>> recipes = [];

      // Read existing metadata if file exists
      if (await metadataFile.exists()) {
        final content = await metadataFile.readAsString();
        recipes = List<Map<String, dynamic>>.from(json.decode(content));
      }

      // Add new recipe metadata
      recipes.add({
        'id': widget.mealId, // Add the meal ID to identify the recipe
        'fileName': fileName,
        'name': recipeName,
        'imageUrl': imageUrl,
        'date': DateTime.now().toIso8601String(),
        'category': recipeDetails['strCategory'] ?? 'Main Course',
        'cuisine': recipeDetails['strArea'] ?? 'International',
      });

      // Save updated metadata
      await metadataFile.writeAsString(json.encode(recipes));
    } catch (e) {
      debugPrint('Failed to save recipe metadata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.deepOrange;

    return AppScaffold(
      key: _scaffoldKey,
      padding: const EdgeInsets.all(0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: AnimatedOpacity(
          opacity: _showTitle ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Text(
            widget.mealName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 20,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Heart icon button with badge showing favorites count
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isFavorite ? Colors.pink.shade50 : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.pink : Colors.grey[700],
                    size: 20,
                  ),
                ),
                onPressed: () {
                  if (isFavorite) {
                    _openFavoritesBottomSheet();
                  } else {
                    _toggleFavorite();
                  }
                },
                tooltip: isFavorite ? 'View favorites' : 'Add to favorites',
              ),
              if (isFavorite)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: const Icon(
                      Icons.done,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.share_outlined,
                color: Colors.black,
                size: 20,
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Sharing recipe...'),
                  duration: const Duration(seconds: 1),
                  backgroundColor: primaryColor,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _fetchRecipeDetails,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        // Hero image with gradient overlay
                        SliverToBoxAdapter(
                          child: Stack(
                            children: [
                              Hero(
                                tag: 'recipe_image_${widget.mealId}',
                                child: Container(
                                  height: 300,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(widget.mealImage),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: .8),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Favorite button overlay
                              Positioned(
                                top: 20,
                                right: 20,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isFavorite
                                        ? Colors.pink.shade50
                                            .withValues(alpha: .9)
                                        : Colors.white.withValues(alpha: .9),
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: .2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      if (isFavorite) {
                                        _openFavoritesBottomSheet();
                                      } else {
                                        _toggleFavorite();
                                      }
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AnimatedSwitcher(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          transitionBuilder: (Widget child,
                                              Animation<double> animation) {
                                            return ScaleTransition(
                                                scale: animation, child: child);
                                          },
                                          child: Icon(
                                            isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            key: ValueKey<bool>(isFavorite),
                                            color: isFavorite
                                                ? Colors.pink
                                                : Colors.grey[700],
                                            size: 24,
                                          ),
                                        ),
                                        if (isFavorite) ...[
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Favorited',
                                            style: TextStyle(
                                              color: Colors.pink,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                left: 20,
                                right: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                (4.0 +
                                                        (widget.mealId
                                                                    .hashCode %
                                                                10) /
                                                            10)
                                                    .toStringAsFixed(1),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: .2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            recipeDetails['strCategory'] ??
                                                'Main Course',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.mealName,
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 10.0,
                                            color: Colors.black,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.white70,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          recipeDetails['strArea'] ??
                                              'International Cuisine',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
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

                        // Recipe stats
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatColumn(
                                  Icons.access_time_rounded,
                                  '30 min',
                                  'Cook Time',
                                  primaryColor,
                                ),
                                _buildDivider(),
                                _buildStatColumn(
                                  Icons.people_alt_outlined,
                                  '4',
                                  'Servings',
                                  primaryColor,
                                ),
                                _buildDivider(),
                                _buildStatColumn(
                                  Icons.local_fire_department_rounded,
                                  '320',
                                  'Calories',
                                  primaryColor,
                                ),
                                _buildDivider(),
                                _buildStatColumn(
                                  Icons.trending_up_rounded,
                                  'Medium',
                                  'Difficulty',
                                  primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Tab bar
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .05),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TabBar(
                              controller: _tabController,
                              onTap: (index) {
                                setState(() {
                                  _selectedTabIndex = index;
                                });
                              },
                              labelColor: primaryColor,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: primaryColor,
                              indicatorSize: TabBarIndicatorSize.label,
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              unselectedLabelStyle: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                              ),
                              tabs: const [
                                Tab(text: 'Ingredients'),
                                Tab(text: 'Instructions'),
                                Tab(text: 'Details'),
                              ],
                            ),
                          ),
                        ),

                        // Tab content
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            child: [
                              _buildIngredientsTab(primaryColor),
                              _buildInstructionsTab(primaryColor),
                              _buildDetailsTab(primaryColor),
                            ][_selectedTabIndex],
                          ),
                        ),

                        // Actions row (Download and View Favorites)
                        // SliverToBoxAdapter(
                        //   child: Container(
                        //     margin: const EdgeInsets.all(16),
                        //     child: Row(
                        //       children: [
                        //         // Download button
                        //         Expanded(
                        //           flex: 2,
                        //           child: ElevatedButton.icon(
                        //             onPressed: _downloadRecipe,
                        //             icon: const Icon(Icons.download_rounded),
                        //             label: const Text('Download'),
                        //             style: ElevatedButton.styleFrom(
                        //               backgroundColor: primaryColor,
                        //               foregroundColor: Colors.white,
                        //               padding: const EdgeInsets.symmetric(
                        //                   vertical: 16),
                        //               shape: RoundedRectangleBorder(
                        //                 borderRadius: BorderRadius.circular(16),
                        //               ),
                        //               elevation: 4,
                        //               shadowColor:
                        //                   primaryColor.withValues(alpha: .4),
                        //             ),
                        //           ),
                        //         ),
                        //         const SizedBox(width: 16),
                        //         // View favorites button
                        //         Expanded(
                        //           flex: 2,
                        //           child: ElevatedButton.icon(
                        //             onPressed: _openFavoritesBottomSheet,
                        //             icon: const Icon(Icons.favorite),
                        //             label: const Text('Favorites'),
                        //             style: ElevatedButton.styleFrom(
                        //               backgroundColor: Colors.pink,
                        //               foregroundColor: Colors.white,
                        //               padding: const EdgeInsets.symmetric(
                        //                   vertical: 16),
                        //               shape: RoundedRectangleBorder(
                        //                 borderRadius: BorderRadius.circular(16),
                        //               ),
                        //               elevation: 4,
                        //               shadowColor:
                        //                   Colors.pink.withValues(alpha: .4),
                        //             ),
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),

                        // // Bottom padding
                        const SliverToBoxAdapter(
                          child: SizedBox(height: 32),
                        ),
                      ],
                    ),

                    // Floating action buttons for quick access
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: AnimatedOpacity(
                        opacity: _showTitle ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Floating favorite button
                            FloatingActionButton(
                              heroTag: 'favoriteBtn',
                              onPressed: isFavorite
                                  ? _openFavoritesBottomSheet
                                  : _toggleFavorite,
                              backgroundColor:
                                  isFavorite ? Colors.pink : Colors.white,
                              foregroundColor:
                                  isFavorite ? Colors.white : Colors.pink,
                              elevation: 4,
                              mini: true,
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Floating download button
                            FloatingActionButton(
                              heroTag: 'downloadBtn',
                              onPressed: _downloadRecipe,
                              backgroundColor: primaryColor,
                              elevation: 4,
                              mini: true,
                              child: const Icon(Icons.download),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.withValues(alpha: .3),
    );
  }

  Widget _buildStatColumn(
      IconData icon, String value, String label, Color primaryColor) {
    return Column(
      children: [
        Icon(
          icon,
          color: primaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsTab(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ingredients',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: ingredients.length,
            separatorBuilder: (context, index) => Divider(
              color: Colors.grey.withValues(alpha: .3),
              height: 16,
            ),
            itemBuilder: (context, index) {
              return Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ingredients[index],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          measures[index],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsTab(Color primaryColor) {
    final instructions = recipeDetails['strInstructions'] ?? '';

    // Improved parsing of instructions to handle different formats
    List<String> steps = [];

    // First try to split by line breaks
    final lineBreakSteps = instructions
        .split(RegExp(r'\r\n|\r|\n'))
        .where((String step) => step.trim().isNotEmpty)
        .toList();

    // If we have multiple steps from line breaks, use those
    if (lineBreakSteps.length > 1) {
      steps = lineBreakSteps;
    } else {
      // Otherwise try to split by numbered steps (e.g., "1. Step one", "2. Step two")
      final numberedSteps =
          RegExp(r'(?:\d+\.\s*)([^\d].*?)(?=\d+\.\s*|$)', dotAll: true)
              .allMatches(instructions)
              .map((match) => match.group(1)?.trim() ?? '')
              .where((String step) => step.isNotEmpty)
              .toList();

      if (numberedSteps.isNotEmpty) {
        steps = numberedSteps;
      } else {
        // If no clear steps, split by sentences
        steps = instructions
            .split(RegExp(r'(?<=[.!?])\s+'))
            .where((String step) => step.trim().isNotEmpty)
            .toList();

        // If still no clear steps, use the whole text
        if (steps.length <= 1) {
          steps = [instructions];
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cooking Instructions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (steps.isEmpty)
            Text(
              instructions,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            )
          else
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: steps.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        steps[index],
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recipe Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailItem(
            'Category',
            recipeDetails['strCategory'] ?? 'Main Course',
            Icons.category_outlined,
            primaryColor,
          ),
          _buildDetailItem(
            'Cuisine',
            recipeDetails['strArea'] ?? 'International',
            Icons.public,
            primaryColor,
          ),
          if (recipeDetails['strSource'] != null &&
              recipeDetails['strSource'].toString().isNotEmpty)
            _buildDetailItem(
              'Source',
              recipeDetails['strSource'],
              Icons.link,
              primaryColor,
            ),
          if (recipeDetails['strYoutube'] != null &&
              recipeDetails['strYoutube'].toString().isNotEmpty)
            _buildDetailItem(
              'Video Tutorial',
              'Watch on YouTube',
              Icons.play_circle_outline,
              primaryColor,
              isLink: true,
            ),
          const SizedBox(height: 16),
          if (recipeDetails['strTags'] != null &&
              recipeDetails['strTags'].toString().isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tags',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: recipeDetails['strTags']
                      .toString()
                      .split(',')
                      .map<Widget>((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: .3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              tag.trim(),
                              style: TextStyle(
                                fontSize: 14,
                                color: primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(
      String label, String value, IconData icon, Color primaryColor,
      {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isLink ? primaryColor : Colors.black87,
                    decoration: isLink ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
