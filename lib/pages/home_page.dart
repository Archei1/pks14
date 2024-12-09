import 'package:flutter/material.dart';
import 'package:pks11/components/item.dart';
import 'package:pks11/model/product.dart';
import 'package:pks11/pages/add_car_page.dart';
import 'package:pks11/api_service.dart';

class HomePage extends StatefulWidget {
  final Function(Car) onFavoriteToggle;
  final List<Car> favoriteCars;
  final Function(Car) onAddToCart;
  final Function(Car) onEdit;

  const HomePage({
    super.key,
    required this.onFavoriteToggle,
    required this.favoriteCars,
    required this.onAddToCart,
    required this.onEdit,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  List<Car> cars = [];
  List<Car> filteredCars = [];
  String searchQuery = '';

  Future<void> loadCars() async {
    final fetchedCars = await apiService.getProducts();
    setState(() {
      cars = fetchedCars;
      filteredCars = fetchedCars;
    });
  }

  @override
  void initState() {
    super.initState();
    loadCars();
  }

  Future<void> _addNewCar(Car car) async {
    try {
      final newCar = await apiService.createProducts(car);
      setState(() {
        cars.add(newCar);
        filteredCars = cars;
      });
    } catch (e) {
      print("Ошибка добавления машины: $e");
    }
  }

  Future<void> _removeCar(int id) async {
    try {
      await apiService.deleteProduct(id);
      setState(() {
        cars.removeWhere((car) => car.id == id);
        filteredCars = cars;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Машина с ID $id удалена")),
      );
    } catch (e) {
      print("Ошибка удаления машины: $e");
    }
  }

  Future<void> _editCarDialog(BuildContext context, Car car) async {
    String title = car.title;
    String description = car.description;
    String imageUrl = car.imageUrl;
    String cost = car.cost;
    String article = car.article;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Редактировать автомобиль'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Название'),
                  controller: TextEditingController(text: title),
                  onChanged: (value) {
                    title = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Описание'),
                  controller: TextEditingController(text: description),
                  onChanged: (value) {
                    description = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'URL картинки'),
                  controller: TextEditingController(text: imageUrl),
                  onChanged: (value) {
                    imageUrl = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Цена'),
                  controller: TextEditingController(text: cost),
                  onChanged: (value) {
                    cost = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Артикул'),
                  controller: TextEditingController(text: article),
                  onChanged: (value) {
                    article = value;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Сохранить'),
              onPressed: () async {
                if (title.isNotEmpty &&
                    description.isNotEmpty &&
                    cost.isNotEmpty &&
                    article.isNotEmpty) {
                  Car updatedCar = Car(
                    car.id,
                    title,
                    description,
                    imageUrl,
                    cost,
                    article,
                  );
                  try {
                    Car result =
                    await apiService.updateProduct(car.id, updatedCar);
                    setState(() {
                      int index = cars.indexWhere((c) => c.id == car.id);
                      if (index != -1) {
                        cars[index] = result;
                        filteredCars = cars;
                      }
                    });
                    Navigator.of(context).pop();
                  } catch (error) {
                    print('Ошибка при обновлении машины: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка: $error')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Пожалуйста, заполните все поля.')
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _filterCars(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredCars = cars.where((car) {
        final titleLower = car.title.toLowerCase();
        final descriptionLower = car.description.toLowerCase();
        return titleLower.contains(searchQuery) ||
            descriptionLower.contains(searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'BMW Модели',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blueGrey,
          actions: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  onChanged: _filterCars,
                  decoration: const InputDecoration(
                    hintText: 'Поиск...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: filteredCars.isNotEmpty
              ? GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: filteredCars.length,
            itemBuilder: (BuildContext context, int index) {
              final car = filteredCars[index];
              final isFavorite = widget.favoriteCars.contains(car);
              return GestureDetector(
                onLongPress: () => _editCarDialog(context, car),
                child: Dismissible(
                  key: Key(car.id.toString()),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    await _removeCar(car.id);
                  },
                  child: ItemNote(
                    car: car,
                    isFavorite: isFavorite,
                    onFavoriteToggle: () => widget.onFavoriteToggle(car),
                    onAddToCart: () => widget.onAddToCart(car),
                    onEdit: () => _editCarDialog(context, car),
                  ),
                ),
              );
            },
          )
              : const Center(child: Text('Нет доступных автомобилей')),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final newCar = await Navigator.push<Car>(
              context,
              MaterialPageRoute(builder: (context) => const AddCarPage()),
            );
            if (newCar != null) {
              await _addNewCar(newCar);
            }
          },
          child: const Icon(Icons.add),
          backgroundColor: Colors.blueGrey,
        ),
      ),
    );
  }
}
