import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/promo_code.dart';
import 'package:kebda_zaman/features/shared/domain/repositories/promo_repository.dart';

class FakePromoRepository implements PromoRepository {
  List<PromoCode> _promos = [];
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('promos_state');
    if (data != null) {
      try {
        final List<dynamic> list = json.decode(data);
        _promos = list
            .map((e) => PromoCode.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _promos = [];
      }
    }
    _initialized = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'promos_state',
      json.encode(_promos.map((p) => p.toJson()).toList()),
    );
  }

  @override
  Future<Result<PromoCode?>> getPromoByCode(String code) async {
    await _init();
    try {
      final promo = _promos.firstWhere(
        (p) => p.code.toUpperCase() == code.toUpperCase(),
      );
      return Success(promo);
    } catch (_) {
      return const Success(null);
    }
  }

  @override
  Future<Result<List<PromoCode>>> getAllPromos() async {
    await _init();
    return Success(List.unmodifiable(_promos));
  }

  @override
  Future<Result<bool>> validatePromo(String code, double orderSubtotal) async {
    await _init();
    try {
      final promo = _promos.firstWhere(
        (p) => p.code.toUpperCase() == code.toUpperCase(),
      );
      if (!promo.isActive) return const Success(false);

      final now = DateTime.now();
      if (now.isBefore(promo.startDate) || now.isAfter(promo.endDate)) {
        return const Success(false);
      }

      if (orderSubtotal < promo.minOrderValue) {
        return const Success(false);
      }

      return const Success(true);
    } catch (_) {
      return const Success(false);
    }
  }

  @override
  Future<Result<void>> createPromo(PromoCode promo) async {
    await _init();
    _promos.add(promo);
    await _save();
    return const Success(null);
  }

  @override
  Future<Result<void>> updatePromo(PromoCode promo) async {
    await _init();
    final idx = _promos.indexWhere((p) => p.id == promo.id);
    if (idx == -1) return const Err(NotFoundFailure('Promo not found'));
    _promos[idx] = promo;
    await _save();
    return const Success(null);
  }

  @override
  Future<Result<void>> deletePromo(String id) async {
    await _init();
    _promos.removeWhere((p) => p.id == id);
    await _save();
    return const Success(null);
  }
}
