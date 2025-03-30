// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:open_file/open_file.dart';

// import 'app_scaffold.dart';

// class RecipeLibraryScreen extends StatefulWidget {
//   const RecipeLibraryScreen({super.key});

//   @override
//   State<RecipeLibraryScreen> createState() => _RecipeLibraryScreenState();
// }

// class _RecipeLibraryScreenState extends State<RecipeLibraryScreen> {
//   List<Map<String, dynamic>> _recipes = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadRecipes();
//   }

//   Future<void> _loadRecipes() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final metadataFile = File('${directory.path}/recipe_library.json');

//       if (await metadataFile.exists()) {
//         final content = await metadataFile.readAsString();
//         final List<dynamic> decoded = json.decode(content);

//         setState(() {
//           _recipes = List<Map<String, dynamic>>.from(decoded);
//           _recipes.sort((a, b) =>
//               DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _recipes = [];
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Failed to load recipes: $e');
//       setState(() {
//         _recipes = [];
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _openRecipe(String fileName) async {
//     try {
//       Directory? directory;

//       if (Platform.isAndroid) {
//         // Try Downloads directory first
//         directory = Directory('/storage/emulated/0/Download');
//         if (!await directory.exists()) {
//           directory = await getExternalStorageDirectory();
//         }
//       } else {
//         directory = await getApplicationDocumentsDirectory();
//       }

//       if (directory == null) {
//         throw Exception('Could not access storage directory');
//       }

//       final filePath = '${directory.path}/$fileName';
//       final file = File(filePath);

//       if (await file.exists()) {
//         await OpenFile.open(filePath);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Recipe file not found'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to open recipe: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<void> _deleteRecipe(int index) async {
//     try {
//       final recipe = _recipes[index];

//       // Remove from UI first
//       setState(() {
//         _recipes.removeAt(index);
//       });

//       // Try to delete the file
//       Directory? directory;

//       if (Platform.isAndroid) {
//         directory = Directory('/storage/emulated/0/Download');
//         if (!await directory.exists()) {
//           directory = await getExternalStorageDirectory();
//         }
//       } else {
//         directory = await getApplicationDocumentsDirectory();
//       }

//       if (directory != null) {
//         final file = File('${directory.path}/${recipe['fileName']}');
//         if (await file.exists()) {
//           await file.delete();
//         }
//       }

//       // Update metadata file
//       final appDir = await getApplicationDocumentsDirectory();
//       final metadataFile = File('${appDir.path}/recipe_library.json');
//       await metadataFile.writeAsString(json.encode(_recipes));

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Recipe deleted'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       // If error, reload the list
//       _loadRecipes();

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to delete recipe: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final primaryColor = Colors.deepOrange;

//     return AppScaffold(
//       appBar: AppBar(
//         title: const Text('My Recipe Library'),
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadRecipes,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? Center(
//               child: CircularProgressIndicator(
//                 color: primaryColor,
//               ),
//             )
//           : _recipes.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.book,
//                         size: 80,
//                         color: Colors.grey[400],
//                       ),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'No recipes saved yet',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'Download recipes to view them here',
//                         style: TextStyle(
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : ListView.builder(
//                   padding: const EdgeInsets.all(1),
//                   itemCount: _recipes.length,
//                   itemBuilder: (context, index) {
//                     final recipe = _recipes[index];
//                     final date = DateTime.parse(recipe['date']);
//                     final formattedDate =
//                         '${date.day}/${date.month}/${date.year}';

//                     return Dismissible(
//                       key: Key(recipe['fileName']),
//                       background: Container(
//                         color: Colors.red,
//                         alignment: Alignment.centerRight,
//                         padding: const EdgeInsets.only(right: 20),
//                         child: const Icon(
//                           Icons.delete,
//                           color: Colors.white,
//                         ),
//                       ),
//                       direction: DismissDirection.endToStart,
//                       onDismissed: (direction) {
//                         _deleteRecipe(index);
//                       },
//                       child: Card(
//                         margin: const EdgeInsets.only(bottom: 16),
//                         elevation: 4,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: InkWell(
//                           onTap: () => _openRecipe(recipe['fileName']),
//                           borderRadius: BorderRadius.circular(12),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               ClipRRect(
//                                 borderRadius: const BorderRadius.vertical(
//                                   top: Radius.circular(12),
//                                 ),
//                                 child: Image.network(
//                                   recipe['imageUrl'],
//                                   height: 150,
//                                   width: double.infinity,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Container(
//                                       height: 150,
//                                       color: Colors.grey[300],
//                                       child: const Center(
//                                         child: Icon(
//                                           Icons.image_not_supported,
//                                           size: 50,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.all(16),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       recipe['name'],
//                                       style: const TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Row(
//                                       children: [
//                                         Icon(
//                                           Icons.category,
//                                           size: 16,
//                                           color: Colors.grey[600],
//                                         ),
//                                         const SizedBox(width: 4),
//                                         Text(
//                                           recipe['category'] ?? 'Main Course',
//                                           style: TextStyle(
//                                             color: Colors.grey[600],
//                                           ),
//                                         ),
//                                         const SizedBox(width: 16),
//                                         Icon(
//                                           Icons.public,
//                                           size: 16,
//                                           color: Colors.grey[600],
//                                         ),
//                                         const SizedBox(width: 4),
//                                         Text(
//                                           recipe['cuisine'] ?? 'International',
//                                           style: TextStyle(
//                                             color: Colors.grey[600],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           'Downloaded: $formattedDate',
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.grey[600],
//                                           ),
//                                         ),
//                                         ElevatedButton.icon(
//                                           onPressed: () =>
//                                               _openRecipe(recipe['fileName']),
//                                           icon: const Icon(Icons.visibility,
//                                               size: 16),
//                                           label: const Text('View'),
//                                           style: ElevatedButton.styleFrom(
//                                             backgroundColor: primaryColor,
//                                             foregroundColor: Colors.white,
//                                             padding: const EdgeInsets.symmetric(
//                                               horizontal: 12,
//                                               vertical: 8,
//                                             ),
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }


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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
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
          _isLoading = false;
        });
      } else {
        setState(() {
          _recipes = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load recipes: $e');
      setState(() {
        _recipes = [];
        _isLoading = false;
      });
    }
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
      final recipe = _recipes[index];

      // Remove from UI first
      setState(() {
        _recipes.removeAt(index);
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
    final recipe = _recipes[index];
    
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
          content: const Text('Are you sure you want to delete all recipes? This action cannot be undone.'),
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
                    final file = File('${directory!.path}/${recipe['fileName']}');
                    if (await file.exists()) {
                      await file.delete();
                    }
                  }
                                  
                  // Clear metadata
                  final appDir = await getApplicationDocumentsDirectory();
                  final metadataFile = File('${appDir.path}/recipe_library.json');
                  await metadataFile.writeAsString(json.encode([]));
                  
                  // Update UI
                  setState(() {
                    _recipes = [];
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
              child: const Text('Delete All', style: TextStyle(color: Colors.red)),
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
          : _recipes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.book,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No recipes saved yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Download recipes to view them here',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(1),
                  itemCount: _recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = _recipes[index];
                    final date = DateTime.parse(recipe['date']);
                    final formattedDate =
                        '${date.day}/${date.month}/${date.year}';

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
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  recipe['imageUrl'],
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
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
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                                          recipe['category'] ?? 'Main Course',
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
                                          recipe['cuisine'] ?? 'International',
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
                                              icon: const Icon(Icons.delete, size: 20),
                                              color: Colors.red,
                                              onPressed: () => _confirmDeleteRecipe(index),
                                              tooltip: 'Delete Recipe',
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                            const SizedBox(width: 12),
                                            ElevatedButton.icon(
                                              onPressed: () =>
                                                  _openRecipe(recipe['fileName']),
                                              icon: const Icon(Icons.visibility,
                                                  size: 16),
                                              label: const Text('View'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: primaryColor,
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 8,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
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
    );
  }
}

