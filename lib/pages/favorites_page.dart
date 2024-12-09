import 'package:flutter/material.dart';
import 'package:pks11/model/product.dart';
import 'package:pks11/components/item.dart';

class FavoritesPage extends StatelessWidget {
  final List<Car> favoriteCars;
  final Function(Car) onFavoriteToggle;
  final Function(Car) onAddToCart;
  final Function(Car) onEdit;

  const FavoritesPage({
    super.key,
    required this.favoriteCars,
    required this.onFavoriteToggle,
    required this.onAddToCart,
    required this.onEdit,

  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Избранное'),
          backgroundColor: Colors.blueGrey,
        ),
        body: favoriteCars.isNotEmpty
            ? ListView.builder(
          itemCount: favoriteCars.length,
          itemBuilder: (context, index) {
            final car = favoriteCars[index];
            return ItemNote(
              car: car,
              isFavorite: true,
              onFavoriteToggle: () => onFavoriteToggle(car),
              onAddToCart: () => onAddToCart(car),
              onEdit: (){
                onEdit(car);
              },
            );
          },
        )
            : const Center(child: Text('Нет избранных автомобилей')),
      ),
    );
  }
}
