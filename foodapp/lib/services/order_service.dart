import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';
import '../models/food_model.dart';
import '../services/cart_service.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CartService _cartService = CartService();

  // Place a new order
  Future<String?> placeOrder(String userId, List<CartItemModel> cartItems, 
      double totalAmount, String? deliveryAddress) async {
    try {
      // Create a new order
      DocumentReference orderRef = await _firestore.collection('orders').add({
        'userId': userId,
        'items': cartItems.map((item) => {
          'foodId': item.food.id,
          'name': item.food.name,
          'price': item.food.price,
          'quantity': item.quantity,
        }).toList(),
        'totalAmount': totalAmount,
        'status': 'pending',
        'orderDate': FieldValue.serverTimestamp(),
        'deliveryAddress': deliveryAddress,
      });
      
      // Update with the generated ID
      await orderRef.update({'id': orderRef.id});
      
      // Clear the cart after successful order
      await _cartService.clearCart(userId);
      
      return orderRef.id;
    } catch (e) {
      debugPrint("Error placing order: ${e.toString()}");
      return null;
    }
  }

  // Get user orders
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('orderDate', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        List<CartItemModel> items = [];
        if (data['items'] != null) {
          for (var item in data['items']) {
            FoodModel food = FoodModel(
              id: item['foodId'],
              name: item['name'],
              description: '', // These fields won't be available in the order
              price: item['price'],
              foodPicture: '', // We don't store the image in the order
            );
            
            items.add(CartItemModel(
              id: item['foodId'],
              food: food,
              quantity: item['quantity'],
            ));
          }
        }
        
        return OrderModel(
          id: data['id'],
          userId: data['userId'],
          items: items,
          totalAmount: data['totalAmount'],
          status: data['status'],
          orderDate: (data['orderDate'] as Timestamp).toDate(),
          deliveryAddress: data['deliveryAddress'],
        );
      }).toList();
    } catch (e) {
      debugPrint("Error getting user orders: ${e.toString()}");
      return [];
    }
  }
}
