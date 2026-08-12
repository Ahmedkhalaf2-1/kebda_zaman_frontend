import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/features/shared/domain/models/payment.dart';

class SavedCardsState {
  final List<SavedCard> cards;
  final bool isLoading;
  final String? errorMessage;

  const SavedCardsState({
    this.cards = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  SavedCardsState copyWith({
    List<SavedCard>? cards,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SavedCardsState(
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class SavedCardsNotifier extends StateNotifier<SavedCardsState> {
  final Ref _ref;

  SavedCardsNotifier(this._ref) : super(const SavedCardsState(isLoading: true)) {
    loadCards();
  }

  Future<void> loadCards() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final repo = _ref.read(paymentRepositoryProvider);
    final result = await repo.getSavedCards();
    result.fold(
      (failure) {
        if (!mounted) return;
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (cards) {
        if (!mounted) return;
        state = SavedCardsState(cards: cards, isLoading: false);
      },
    );
  }

  Future<bool> deleteCard(String cardId) async {
    final repo = _ref.read(paymentRepositoryProvider);
    final result = await repo.deleteSavedCard(cardId);
    if (result.isSuccess) {
      await loadCards();
      return true;
    }
    state = state.copyWith(errorMessage: result.failure.message);
    return false;
  }
}

final savedCardsNotifierProvider =
    StateNotifierProvider<SavedCardsNotifier, SavedCardsState>((ref) {
      return SavedCardsNotifier(ref);
    });
