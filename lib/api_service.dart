import 'package:dio/dio.dart';
import 'package:pks11/model/product.dart';

import 'model/order.dart';
import 'model/order_create.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.192.223.253:8080',
      connectTimeout: const Duration(seconds: 50),
      receiveTimeout: const Duration(seconds: 50),
    ),
  );

  Future<List<Car>> getProducts() async {
    try {
      final response = await _dio.get('http://10.192.223.253:8080/products');
      if (response.statusCode == 200) {
        List<Car> carList = (response.data as List)
            .map((car) => Car.fromJson(car))
            .toList();
        return carList;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<Car> createProducts(Car car) async {
    try {
      final response = await _dio.post(
        'http://10.192.223.253:8080/products/create',
        data: car.toJson(),
      );
      if (response.statusCode == 200) {
        return Car.fromJson(response.data);
      } else {
        throw Exception('Failed to create car: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating car: $e');
    }
  }

  Future<Car> getProductById(int id) async {
    try {
      final response = await _dio.get('http://10.192.223.253:8080/products/$id');
      if (response.statusCode == 200) {
        return Car.fromJson(response.data);
      } else {
        throw Exception('Failed to load car with ID $id: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching car by ID: $e');
    }
  }

  Future<Car> updateProduct(int id, Car car) async {
    try {
      final response = await _dio.put(
        'http://10.192.223.253:8080/products/update/$id',
        data: car.toJson(),
      );
      if (response.statusCode == 200) {
        return Car.fromJson(response.data);
      } else {
        throw Exception('Failed to update car: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating car: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      final response = await _dio.delete('http://10.192.223.253:8080/products/delete/$id');
      if (response.statusCode == 204) {
        print("Car with ID $id deleted successfully.");
      } else {
        throw Exception('Failed to delete car: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting car: $e');
    }
  }
  // Создание заказа
  Future<Order> createOrder(OrderCreate orderCreate) async {
    try {
      final response = await _dio.post(
        'http://85.192.40.154:8000/orders/',
        data: orderCreate.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Order.fromJson(response.data);
      } else {
        throw Exception('Не удалось создать заказ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при создании заказа: $e');
    }
  }

  // Получение заказов пользователя
  Future<List<Order>> getOrdersByUser(String userId) async {
    try {
      final response = await _dio.get('http://85.192.40.154:8000/orders/user/$userId');
      if (response.statusCode == 200) {
        List<Order> orders = (response.data as List)
            .map((order) => Order.fromJson(order))
            .toList();
        return orders;
      } else {
        throw Exception('Не удалось загрузить заказы: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при получении заказов: $e');
    }
  }

  Future<List<Car>> getProductsByIds(List<int> productIds) async {
    try {
      // Используем Future.wait для параллельного получения всех продуктов
      List<Future<Car>> fetches = productIds.map((id) => getProductById(id)).toList();
      return await Future.wait(fetches);
    } catch (e) {
      throw Exception('Ошибка при получении продуктов: $e');
    }
  }
}
