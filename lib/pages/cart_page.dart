import 'package:flutter/material.dart';
import 'package:pks11/model/product.dart';
import 'package:pks11/api_service.dart';

class CartItem {
  final Car car;
  int quantity;

  CartItem({
    required this.car,
    required this.quantity,
  });
}

class CartPage extends StatelessWidget {
  final List<CartItem> cartItems;
  final Function(Car) onRemove;
  final Function(Car, int) onUpdateQuantity;
  final ApiService apiService = ApiService();

  CartPage({
    super.key,
    required this.cartItems,
    required this.onRemove,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    double total = cartItems.fold(0, (sum, item) {
      String numeric = item.car.cost.replaceAll(RegExp(r'[^\d]'), '');
      return sum + (double.tryParse(numeric) ?? 0) * item.quantity;
    });

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Корзина'),
          backgroundColor: Colors.blueGrey,
        ),
        body: cartItems.isNotEmpty
            ? Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
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
                                  await apiService.deleteProduct(item.car.id);
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text('Удалить'),
                              ),
                            ],
                          ),
                        );
                      }
                      return Future.value(false);
                    },
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        onRemove(item.car);
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
                                  onUpdateQuantity(item.car, item.quantity - 1);
                                }
                              },
                            ),
                            Text(item.quantity.toString()),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                onUpdateQuantity(item.car, item.quantity + 1);
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Покупка оформлена!')),
                      );
                    },
                    child: const Text('Купить'),
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
      ),
    );
  }
}
