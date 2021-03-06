import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shop/models/cart.dart';
import 'package:shop/models/cart_item.dart';
import 'package:shop/models/order.dart';
import 'package:shop/utils/constants.dart';

class OrderList with ChangeNotifier {
  List<Order> _items = [];

  List<Order> get items {
    return [..._items];
  }

  int get itemsCount {
    return _items.length;
  }

  Future<void> addOrder(Cart cart) async {
    final date = DateTime.now();
    final response =
        await http.post(Uri.parse('${Constants.ORDER_BASE_URL}.json'),
            body: jsonEncode({
              'total': cart.totalAmount,
              'date': date.toIso8601String(),
              'products': cart.items.values
                  .map((e) => {
                        'id': e.id,
                        'productId': e.productId,
                        'name': e.name,
                        'quantity': e.quantity,
                        'price': e.price,
                      })
                  .toList()
            }));

    final id = jsonDecode(response.body)['name'];

    _items.insert(
        0,
        Order(
          id: id,
          total: cart.totalAmount,
          products: cart.items.values.toList(),
          date: date,
        ));
    notifyListeners();
  }

  Future<void> loadOrders() async {
    _items.clear();
    final response =
        await http.get(Uri.parse('${Constants.ORDER_BASE_URL}.json'));

    if (response.body == 'null') return;
    Map<String, dynamic> data = jsonDecode(response.body);
    data.forEach((orderId, orderData) {
      _items.add(
        Order(
            id: orderId,
            date: DateTime.parse(orderData['date']),
            total: orderData['total'],
            products: (orderData['products'] as List<dynamic>).map((item) {
              return CartItem(
                price: item['price'],
                id: item['id'],
                name: item['name'],
                productId: item['productId'],
                quantity: item['quantity'],
              );
            }).toList(),
        ),
      );
    });
    notifyListeners();
  }
}
