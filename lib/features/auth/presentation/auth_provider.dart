import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

enum UserRole { customer, seller, none }

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserRole role;
  final String? email;
  final String? name;
  final int? userId;
  final String? token; // JWT Token

  AuthState({
    this.isLoading = false, 
    this.isAuthenticated = false,
    this.role = UserRole.none,
    this.email,
    this.name,
    this.userId,
    this.token,
  });
}

class AuthNotifier extends Notifier<AuthState> {
  static const String baseUrl = 'http://10.0.2.2:8080/api/auth';
  static const _storage = FlutterSecureStorage();

  @override
  AuthState build() {
    // Uygulama açılışında kayıtlı token'ı kontrol et
    _tryAutoLogin();
    return AuthState(); 
  }

  Future<void> _tryAutoLogin() async {
    final token = await _storage.read(key: 'jwt_token');
    final email = await _storage.read(key: 'user_email');
    final name = await _storage.read(key: 'user_name');
    final role = await _storage.read(key: 'user_role');
    final userId = await _storage.read(key: 'user_id');

    if (token != null && email != null) {
      state = AuthState(
        isLoading: false,
        isAuthenticated: true,
        role: role == 'SELLER' ? UserRole.seller : UserRole.customer,
        email: email,
        name: name,
        userId: int.tryParse(userId ?? '0'),
        token: token,
      );
    }
  }

  Future<void> login(String email, String password, UserRole selectedRole, {String? name}) async {
    state = AuthState(isLoading: true);
    
    try {
      if (name != null) {
        final regResponse = await http.post(
          Uri.parse('$baseUrl/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
            'role': selectedRole == UserRole.seller ? 'SELLER' : 'CUSTOMER'
          }),
        ).timeout(const Duration(seconds: 5));

        if (regResponse.statusCode == 409) {
          throw Exception('Bu e-posta zaten kullanılıyor.');
        }
        if (regResponse.statusCode != 200 && regResponse.statusCode != 201) {
          throw Exception('Kayıt başarısız (${regResponse.statusCode})');
        }
      }

      final loginResponse = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 5));

      if (loginResponse.statusCode == 200) {
        final data = jsonDecode(loginResponse.body);
        final token = data['token'] as String;

        // Token'ı güvenli depoya kaydet
        await _storage.write(key: 'jwt_token', value: token);
        await _storage.write(key: 'user_email', value: data['email']);
        await _storage.write(key: 'user_name', value: data['name']);
        await _storage.write(key: 'user_role', value: data['role']);
        await _storage.write(key: 'user_id', value: data['id'].toString());

        state = AuthState(
          isLoading: false,
          isAuthenticated: true,
          role: data['role'] == 'SELLER' ? UserRole.seller : UserRole.customer,
          email: data['email'],
          name: data['name'],
          userId: data['id'],
          token: token,
        );
        return;
      } else {
        throw Exception('Geçersiz e-posta veya şifre.');
      }
    } catch (e) {
      // Fallback: Backend kapalıysa yerel giriş
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('HandshakeException') ||
          e.toString().contains('Failed host lookup')) {
        state = AuthState(
          isLoading: false,
          isAuthenticated: true,
          role: selectedRole,
          email: email,
          name: name ?? email.split('@').first,
          userId: 0,
          token: null,
        );
        return;
      }
      state = AuthState(isLoading: false, isAuthenticated: false);
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});