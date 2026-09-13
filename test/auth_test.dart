import 'package:flutter_test/flutter_test.dart';
import 'package:flowerist_app/features/auth/presentation/auth_provider.dart';

void main() {
  group('AuthState', () {
    test('Varsayılan state authenticated olmamalı', () {
      final state = AuthState();
      expect(state.isAuthenticated, false);
      expect(state.isLoading, false);
      expect(state.role, UserRole.none);
      expect(state.email, isNull);
      expect(state.name, isNull);
      expect(state.userId, isNull);
      expect(state.token, isNull);
    });

    test('Authenticated state doğru kurulmalı', () {
      final state = AuthState(
        isAuthenticated: true,
        role: UserRole.customer,
        email: 'test@test.com',
        name: 'Test User',
        userId: 42,
        token: 'jwt.token.here',
      );
      expect(state.isAuthenticated, true);
      expect(state.role, UserRole.customer);
      expect(state.email, 'test@test.com');
      expect(state.name, 'Test User');
      expect(state.userId, 42);
      expect(state.token, 'jwt.token.here');
    });

    test('Loading state doğru kurulmalı', () {
      final state = AuthState(isLoading: true);
      expect(state.isLoading, true);
      expect(state.isAuthenticated, false);
    });

    test('Seller rolü doğru atanmalı', () {
      final state = AuthState(
        isAuthenticated: true,
        role: UserRole.seller,
      );
      expect(state.role, UserRole.seller);
      expect(state.role != UserRole.customer, true);
    });
  });

  group('UserRole', () {
    test('Tüm roller tanımlı olmalı', () {
      expect(UserRole.values.length, 3);
      expect(UserRole.values.contains(UserRole.customer), true);
      expect(UserRole.values.contains(UserRole.seller), true);
      expect(UserRole.values.contains(UserRole.none), true);
    });
  });
}
