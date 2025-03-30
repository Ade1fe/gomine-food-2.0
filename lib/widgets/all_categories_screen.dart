// import 'package:flutter/material.dart';
// import 'dart:math';

// import 'category_detail_screen.dart' show CategoryDetailScreen;

// class AllCategoriesScreen extends StatelessWidget {
//   final List<dynamic> categories;
//   final Random _random = Random();

//   AllCategoriesScreen({Key? key, required this.categories}) : super(key: key);

//   String _getRandomCookingTime() {
//     return '${_random.nextInt(30) + 10} mins';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('All Categories'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: categories.length,
//         itemBuilder: (context, index) {
//           final category = categories[index];
//           return GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => CategoryDetailScreen(
//                     category: category,
//                     cookingTime: _getRandomCookingTime(),
//                   ),
//                 ),
//               );
//             },
//             child: Container(
//               margin: const EdgeInsets.only(bottom: 16),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: Stack(
//                   children: [
//                     // Image with gradient overlay
//                     ShaderMask(
//                       shaderCallback: (rect) {
//                         return LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                             Colors.transparent,
//                             Colors.black.withOpacity(0.7),
//                           ],
//                         ).createShader(rect);
//                       },
//                       blendMode: BlendMode.darken,
//                       child: Image.network(
//                         category.strCategoryThumb,
//                         width: MediaQuery.of(context).size.width,
//                         height: 180,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     // Info container
//                     Positioned(
//                       bottom: 16,
//                       left: 16,
//                       right: 16,
//                       child: Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           color: Colors.white.withOpacity(0.9),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.1),
//                               blurRadius: 4,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     category.strCategory,
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.black87,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     category.strCategoryDescription,
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.black54,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.orange.withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Text(
//                                 _getRandomCookingTime(),
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.orange,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
