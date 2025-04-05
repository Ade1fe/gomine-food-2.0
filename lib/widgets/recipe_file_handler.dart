import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:android_intent_plus/android_intent.dart';

class RecipeFileHandler {
  /// Checks all possible storage locations for a recipe file
  /// Returns the file if found, null otherwise
  static Future<File?> findRecipeFile(String fileName) async {
    List<Directory> possibleDirectories = [];
    
    try {
      // Try Downloads directory first (Android)
      if (Platform.isAndroid) {
        possibleDirectories.add(Directory('/storage/emulated/0/Download'));
      }
      
      // Try external storage directory
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        possibleDirectories.add(externalDir);
      }
      
      // Always check app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      possibleDirectories.add(appDir);
      
      // Check each directory for the file
      for (var dir in possibleDirectories) {
        if (await dir.exists()) {
          final file = File('${dir.path}/$fileName');
          if (await file.exists()) {
            return file;
          }
        }
      }
      
      return null; // File not found in any location
    } catch (e) {
      debugPrint('Error finding recipe file: $e');
      return null;
    }
  }
  
  /// Opens a recipe file with proper error handling
  static Future<bool> openRecipeFile(BuildContext context, String fileName) async {
    try {
      final file = await findRecipeFile(fileName);
      
      if (file == null) {
        // File not found in any location
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe file not found. It may have been moved or deleted.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      
      // For Android, try multiple methods to open the PDF
      if (Platform.isAndroid) {
        // Try OpenFile first
        final result = await OpenFile.open(file.path);
        if (result.type == ResultType.done) {
          return true;
        }
        
        // If OpenFile fails, try Intent
        try {
          final uri = Uri.parse(file.path);
          final intent = AndroidIntent(
            action: 'android.intent.action.VIEW',
            data: uri.toString(),
            type: 'application/pdf',
          );
          await intent.launch();
          return true;
        } catch (e) {
          // If both methods fail, show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unable to open PDF: $e'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
      } else {
        // For iOS and other platforms
        await OpenFile.open(file.path);
        return true;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening recipe: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}

