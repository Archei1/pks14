import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pks11/model/product.dart';

import '../api_service.dart';
import '../model/order_create.dart';

class CartItem {
  final Car car;
  int quantity;

  CartItem({
    required this.car,
    required this.quantity,
  });
}

class CartPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final Function(Car) onRemove;
  final Function(Car, int) onUpdateQuantity;

  const CartPage({
    Key? key,
    required this.cartItems,
    required this.onRemove,
    required this.onUpdateQuantity,
  }) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ApiService apiService = ApiService();
  bool _isLoading = false;

  Future<String> _getUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      throw Exception('Пользователь не авторизован');
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = widget.cartItems.fold(0, (sum, item) {
      String numeric = item.car.cost.replaceAll(RegExp(r'[^\d.]'), '');
      return sum + (double.tryParse(numeric) ?? 0) * item.quantity;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Корзина',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Open-Sans',
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : widget.cartItems.isNotEmpty
          ? Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                return Dismissible(
                  key: Key(item.car.id.toString()),
                  direction: DismissDirection.horizontal,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      return await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Подтверждение'),
                          content: const Text('Удалить товар из корзины?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Отмена'),
                            ),
                            TextButton(
                              onPressed: () async {
                                try {
                                  await apiService.deleteProduct(item.car.id);
                                  Navigator.of(context).pop(true);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Ошибка при удалении продукта: $e')),
                                  );
                                  Navigator.of(context).pop(false);
                                }
                              },
                              child: const Text('Удалить'),
                            ),
                          ],
                        ),
                      );
                    }
                    return false;
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      widget.onRemove(item.car);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${item.car.title} удален из корзины")),
                      );
                    }
                  },
                  child: ListTile(
                    leading: Image.network(
                      item.car.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                    ),
                    title: Text(item.car.title),
                    subtitle: Text('${item.car.cost} руб.'),
                    trailing: SizedBox(
                      width: 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              if (item.quantity > 1) {
                                widget.onUpdateQuantity(item.car, item.quantity - 1);
                              }
                            },
                          ),
                          Text(item.quantity.toString()),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              widget.onUpdateQuantity(item.car, item.quantity + 1);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Итого:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${total.toStringAsFixed(2)} рублей',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      String userId = await _getUserId();
                      List<int> productIds = widget.cartItems.map((item) => item.car.id).toList();
                      List<int> quantities = widget.cartItems.map((item) => item.quantity).toList();

                      OrderCreate newOrder = OrderCreate(
                        customerId: userId,
                        productIds: productIds,
                        quantities: quantities,
                        totalPrice: total,
                      );

                      await apiService.createOrder(newOrder);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Покупка оформлена!')),
                      );

                      // Очистка корзины после успешной покупки
                      setState(() {
                        widget.cartItems.clear();
                      });
                      //Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ошибка при оформлении покупки: $e')),
                      );
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  child: const Text(
                    'Купить',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      )
          : const Center(child: Text('Ваша корзина пуста')),
    );
  }
}