import 'dart:math';

import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/user.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/auth_repository.dart';
import 'package:uuid/uuid.dart';

class FakeAuthRepository implements AuthRepository {
  User? _currentUser;
  final _random = Random();

  Future<void> _simulateDelay() async {
    final ms = 200 + _random.nextInt(600);
    await Future.delayed(Duration(milliseconds: ms));
  }

  @override
  Future<Result<User>> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network

    // Check mocked users
    if (email == 'admin@kebdazaman.com' && password == 'admin123') {
      _currentUser = User(
        id: 'admin_123',
        phone: '01000000000',
        name: 'Admin User',
        email: email,
        createdAt: DateTime.now(),
      );
      return Success(_currentUser!);
    } else {
      _currentUser = User(
        id: const Uuid().v4(),
        phone: '01000000000',
        name: email.split('@').first,
        email: email,
        createdAt: DateTime.now(),
      );
      return Success(_currentUser!);
    }
  }

  @override
  Future<Result<User>> adminLogin(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network

    // Check mocked users
    if (email == 'admin@kebdazaman.com' && password == 'admin123') {
      _currentUser = User(
        id: 'admin_123',
        phone: '01000000000',
        name: 'Admin User',
        email: email,
        createdAt: DateTime.now(),
      );
      return Success(_currentUser!);
    }

    return const Err(AuthFailure('Invalid admin email or password'));
  }

  @override
  Future<Result<User>> googleLogin(String firebaseIdToken) async {
    await _simulateDelay();
    if (firebaseIdToken.trim().isEmpty) {
      return const Err(AuthFailure('Invalid Google authentication token'));
    }
    _currentUser = User(
      id: const Uuid().v4(),
      name: 'Google User',
      email: 'google.user@example.com',
      createdAt: DateTime.now(),
    );
    return Success(_currentUser!);
  }

  @override
  Future<Result<User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _simulateDelay();
    _currentUser = User(
      id: const Uuid().v4(),
      phone: phone,
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );
    return Success(_currentUser!);
  }

  @override
  Future<Result<User>> guestLogin() async {
    await _simulateDelay();
    _currentUser = User(
      id: const Uuid().v4(),
      phone: '01000000000',
      name: 'Guest User',
      createdAt: DateTime.now(),
    );
    return Success(_currentUser!);
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Success(_currentUser); // Can return null if no one logged in
  }

  @override
  Future<Result<User>> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
    String? locale,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_currentUser == null) {
      return const Err(AuthFailure('Not logged in'));
    }
    _currentUser = _currentUser!.copyWith(
      name: name ?? _currentUser!.name,
      phone: phone ?? _currentUser!.phone,
    );
    return Success(_currentUser!);
  }

  @override
  Future<Result<void>> logout() async {
    await _simulateDelay();
    _currentUser = null;
    return const Success(null);
  }

  @override
  Future<Result<void>> deleteAccount() async {
    await _simulateDelay();
    if (_currentUser == null) {
      return const Err(AuthFailure('Not logged in'));
    }
    _currentUser = null;
    return const Success(null);
  }
}
