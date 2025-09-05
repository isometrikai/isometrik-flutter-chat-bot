// import 'package:flutter/material.dart';
// import 'package:chat_bot/services/cart_manager.dart';
//
// class CartManagerExample extends StatefulWidget {
//   const CartManagerExample({Key? key}) : super(key: key);
//
//   @override
//   State<CartManagerExample> createState() => _CartManagerExampleState();
// }
//
// class _CartManagerExampleState extends State<CartManagerExample> {
//   // final CartManager cartManager = CartManager();
//   Map<String, int> currentQuantities = {};
//
//   @override
//   void initState() {
//     super.initState();
//     // Listen to quantity changes
//     cartManager.quantityStream.listen((quantities) {
//       setState(() {
//         currentQuantities = quantities;
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.all(8.0),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Cart Manager Example',
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),
//             const SizedBox(height: 16),
//
//             // Display current quantities
//             Text(
//               'Current Cart:',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 8),
//
//             if (currentQuantities.isEmpty)
//               const Text('Cart is empty')
//             else
//               ...currentQuantities.entries.map((entry) =>
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('Product ${entry.key}:'),
//                       Text('${entry.value} items'),
//                     ],
//                   ),
//                 )
//               ),
//
//             const SizedBox(height: 16),
//
//             // Summary
//             Text(
//               'Total Items: ${cartManager.totalItems}',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             Text(
//               'Unique Products: ${cartManager.uniqueProductCount}',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//
//             const SizedBox(height: 16),
//
//             // Action buttons
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => cartManager.addProduct('product1'),
//                     child: const Text('Add Product 1'),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => cartManager.removeProduct('product1'),
//                     child: const Text('Remove Product 1'),
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 8),
//
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => cartManager.addProduct('product2'),
//                     child: const Text('Add Product 2'),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => cartManager.removeProduct('product2'),
//                     child: const Text('Remove Product 2'),
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 8),
//
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () => cartManager.clearCart(),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: const Text('Clear Cart'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
