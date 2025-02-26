// import 'package:flutter/material.dart';

// class ProductCard extends StatefulWidget {
//   final VoidCallback onTap;
//   final List<dynamic> products;
//   const ProductCard({
//     super.key,
//     required this.onTap,
//     required this.products,
//   });

//   @override
//   State<ProductCard> createState() => _ProductCardState();
// }

// class _ProductCardState extends State<ProductCard> {
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       borderRadius: BorderRadius.circular(10),
//       onTap: widget.onTap,
//       child: Card(
//         color: Theme.of(context).cardColor,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8),
//           side: BorderSide(
//             color: selectedIndex == index
//                 ? Theme.of(context).colorScheme.primary
//                 : Colors.grey,
//             width: 1,
//           ),
//         ),
//         elevation: 3,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: Container(
//                 decoration: BoxDecoration(
//                   // color: Theme.of(context).cardColor,
//                   borderRadius: BorderRadius.circular(5.0),
//                 ),
//                 child: Center(
//                   child: MouseRegion(
//                     onEnter: (_) =>
//                         setState(() => _scale = 1.2), // Zoom in on hover
//                     onExit: (_) =>
//                         setState(() => _scale = 1.0), // Reset on exit
//                     child: TweenAnimationBuilder(
//                       tween: Tween<double>(begin: 1.0, end: _scale),
//                       duration: Duration(milliseconds: 200),
//                       builder: (context, scale, child) {
//                         return Transform.scale(
//                           scale: scale,
//                           child: child,
//                         );
//                       },
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(
//                             10), // Optional: rounded corners
//                         child: Image.network(
//                           height: 190.0,
//                           product['thumbnail'] ??
//                               '', // Replace with the product image URL
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     overflow: TextOverflow.ellipsis,
//                     product['title'] ?? '',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '\$ ${product['price'] ?? 0.0}',
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Stock: ${product['stock'] ?? 0}',
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
