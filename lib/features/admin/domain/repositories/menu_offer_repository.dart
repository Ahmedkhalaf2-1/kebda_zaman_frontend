import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/features/shared/domain/models/menu_offer.dart';

abstract class MenuOfferRepository {
  Future<Result<List<MenuOffer>>> getMenuOffers();

  /// [offer.id]/[offer.createdAt]/[offer.updatedAt]/[offer.menuItem] are
  /// ignored — only the writable fields are sent (see
  /// `ApiMenuOfferRepository._buildPayload`).
  Future<Result<void>> createMenuOffer(MenuOffer offer);

  Future<Result<void>> updateMenuOffer(MenuOffer offer);

  Future<Result<void>> deleteMenuOffer(String id);
}
