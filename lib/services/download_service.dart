// // lib/services/download_service.dart
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';

// class DownloadService {
//   // Singleton pattern
//   static final DownloadService _instance = DownloadService._internal();
//   factory DownloadService() => _instance;
//   DownloadService._internal();

//   // Stream controller to broadcast download count changes
//   final ValueNotifier<int> downloadCount = ValueNotifier<int>(0);

//   // Initialize the service by loading the current count
//   Future<void> initialize() async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final metadataFile = File('${directory.path}/recipe_library.json');

//       if (await metadataFile.exists()) {
//         final content = await metadataFile.readAsString();
//         final List<dynamic> recipes = json.decode(content);
//         downloadCount.value = recipes.length;
//       } else {
//         downloadCount.value = 0;
//       }
//     } catch (e) {
//       print('Error initializing download service: $e');
//       downloadCount.value = 0;
//     }
//   }

//   // Increment the download count
//   void incrementDownloadCount() {
//     downloadCount.value++;
//   }

//   // Get the current download count
//   int getDownloadCount() {
//     return downloadCount.value;
//   }
// }

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';

// class DownloadService {
//   // Singleton pattern
//   static final DownloadService _instance = DownloadService._internal();
//   factory DownloadService() => _instance;
//   DownloadService._internal();

//   // Check if a recipe is already downloaded
//   Future<bool> isRecipeDownloaded(String recipeId, String recipeName) async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final metadataFile = File('${directory.path}/recipe_library.json');

//       // If the metadata file doesn't exist, no recipes have been downloaded
//       if (!await metadataFile.exists()) {
//         return false;
//       }

//       // Read the metadata file
//       final content = await metadataFile.readAsString();
//       final recipes = List<Map<String, dynamic>>.from(json.decode(content));

//       // Check if the recipe exists in the library
//       return recipes.any((recipe) =>
//         recipe['id'] == recipeId ||
//         recipe['name'].toString().toLowerCase() == recipeName.toLowerCase()
//       );
//     } catch (e) {
//       debugPrint('Error checking if recipe is downloaded: $e');
//       return false;
//     }
//   }

//   // Increment download count (for analytics)
//   Future<void> incrementDownloadCount() async {
//     // Implementation remains the same
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  // Singleton pattern
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  // Stream controller to broadcast download count changes
  final ValueNotifier<int> downloadCount = ValueNotifier<int>(0);

  // Initialize the service by loading the current count
  Future<void> initialize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final metadataFile = File('${directory.path}/recipe_library.json');

      if (await metadataFile.exists()) {
        final content = await metadataFile.readAsString();
        final List<dynamic> recipes = json.decode(content);
        downloadCount.value = recipes.length;
      } else {
        downloadCount.value = 0;
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error initializing download service: $e');
      downloadCount.value = 0;
    }
  }

  // Increment the download count
  void incrementDownloadCount() {
    downloadCount.value++;
  }

  // Get the current download count
  int getDownloadCount() {
    return downloadCount.value;
  }

  // Check if a recipe is already downloaded
  Future<bool> isRecipeDownloaded(String recipeId, String recipeName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final metadataFile = File('${directory.path}/recipe_library.json');

      // If the metadata file doesn't exist, no recipes have been downloaded
      if (!await metadataFile.exists()) {
        return false;
      }

      // Read the metadata file
      final content = await metadataFile.readAsString();
      final recipes = List<Map<String, dynamic>>.from(json.decode(content));

      // Check if the recipe exists in the library
      // First try to match by ID, then by name (case insensitive)
      return recipes.any((recipe) =>
          (recipe['id'] != null && recipe['id'] == recipeId) ||
          recipe['name'].toString().toLowerCase() == recipeName.toLowerCase());
    } catch (e) {
      debugPrint('Error checking if recipe is downloaded: $e');
      return false;
    }
  }
}
