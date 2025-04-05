import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

// This class handles recovery options when a recipe file is missing
class RecipeRecovery {
  // Try to recover recipe by ID from the API
  static Future<bool> recoverRecipeById(BuildContext context, String recipeId, String recipeName) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text('Attempting to recover "$recipeName"...'),
              ],
            ),
          );
        },
      );

      // Try to fetch the recipe from the API
      final response = await http.get(
        Uri.parse('https://www.themealdb.com/api/json/v1/1/lookup.php?i=$recipeId'),
      );

      // Close the loading dialog
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          // Recipe found in API, show recovery options
          return await _showRecoveryOptions(context, recipeId, recipeName);
        } else {
          // Recipe not found in API
          _showRecoveryFailedDialog(context);
          return false;
        }
      } else {
        // API request failed
        _showRecoveryFailedDialog(context);
        return false;
      }
    } catch (e) {
      // Close the loading dialog if still showing
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recovery failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  // Show recovery options dialog
  static Future<bool> _showRecoveryOptions(BuildContext context, String recipeId, String recipeName) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recipe File Missing'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('The recipe file for "$recipeName" could not be found.'),
              const SizedBox(height: 16),
              const Text('Would you like to:'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Re-download Recipe'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
                // Navigate to recipe detail screen to re-download
                Navigator.pushNamed(
                  context,
                  '/recipe-detail',
                  arguments: {
                    'id': recipeId,
                    'name': recipeName,
                    'isRecovery': true,
                  },
                );
              },
            ),
          ],
        );
      },
    ) ?? false;
  }

  // Show recovery failed dialog
  static void _showRecoveryFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recovery Failed'),
          content: const Text(
            'We couldn\'t recover this recipe. It may no longer be available in our database.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Check if a recipe exists in favorites
  static Future<Map<String, dynamic>?> getRecipeFromFavorites(String recipeId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final favoritesFile = File('${directory.path}/favorite_recipes.json');

      if (await favoritesFile.exists()) {
        final content = await favoritesFile.readAsString();
        final List<dynamic> favorites = json.decode(content);

        // Find the recipe in favorites
        for (var favorite in favorites) {
          if (favorite['id'] == recipeId) {
            return Map<String, dynamic>.from(favorite);
          }
        }
      }
      return null;
    } catch (e) {
      print('Error getting recipe from favorites: $e');
      return null;
    }
  }
}

