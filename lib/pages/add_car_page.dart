import 'package:flutter/material.dart';
import 'package:pks11/model/product.dart';
import 'package:pks11/api_service.dart';

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key});

  @override
  _AddCarPageState createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  String title = '';
  String description = '';
  String imageUrl = '';
  String cost = '';
  String article = '';
  bool isLoading = false;

  Future<void> _addCar() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() {
      isLoading = true;
    });

    final newCar = Car(
      DateTime.now().millisecondsSinceEpoch,
      title,
      description,
      imageUrl,
      cost,
      article,
    );

    try {
      final createdCar = await _apiService.createProducts(newCar);
      Navigator.pop(context, createdCar);  // Возвращаем новый объект на предыдущий экран
    } catch (e) {
      // Отображение ошибки при создании автомобиля
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при добавлении автомобиля: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Добавить новый автомобиль'),
          backgroundColor: Colors.blueGrey,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Название'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Пожалуйста, введите название'
                        : null,
                    onSaved: (value) => title = value!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Описание'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Пожалуйста, введите описание'
                        : null,
                    onSaved: (value) => description = value!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration:
                    const InputDecoration(labelText: 'URL изображения'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Пожалуйста, введите URL изображения';
                      }
                      if (!Uri.parse(value).isAbsolute) {
                        return 'Введите корректный URL';
                      }
                      return null;
                    },
                    onSaved: (value) => imageUrl = value!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Цена'),
                    validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Пожалуйста, введите цену'
                        : null,
                    onSaved: (value) => cost = value!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Артикул'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Пожалуйста, введите артикул'
                        : null,
                    onSaved: (value) => article = value!,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : _addCar,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Добавить'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
