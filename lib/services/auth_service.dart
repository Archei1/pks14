import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> signUpWithEmailPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception("Неизвестная ошибка: $e");
    }
  }

  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw Exception("Неизвестная ошибка: $e");
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return Exception("Некорректный email.");
      case 'user-disabled':
        return Exception("Пользователь отключен.");
      case 'user-not-found':
        return Exception("Пользователь не найден.");
      case 'wrong-password':
        return Exception("Неверный пароль.");
      case 'email-already-in-use':
        return Exception("Email уже используется.");
      case 'operation-not-allowed':
        return Exception("Операция не разрешена.");
      case 'weak-password':
        return Exception("Пароль слишком слабый.");
      default:
        return Exception("Ошибка: ${e.message}");
    }
  }
}