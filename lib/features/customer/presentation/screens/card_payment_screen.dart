import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:moyasar/moyasar.dart' as moyasar;
import 'package:kebda_zaman/core/di/providers.dart';
import 'package:kebda_zaman/core/api/api_exceptions.dart';
import 'package:kebda_zaman/core/errors/errors.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';
import 'package:kebda_zaman/core/utils/currency_formatter.dart';
import 'package:kebda_zaman/core/utils/card_brand_gradient.dart';
import 'package:kebda_zaman/core/widgets/kz_button.dart';
import 'package:kebda_zaman/core/widgets/kz_state_views.dart';
import 'package:kebda_zaman/features/shared/domain/models/order.dart';
import 'package:kebda_zaman/features/shared/domain/models/payment.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/auth_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/notifiers/saved_cards_notifier.dart';
import 'package:kebda_zaman/features/customer/presentation/screens/saved_card_3ds_screen.dart';

/// Card checkout: creates the Moyasar payment intent for [order], hands it
/// to the Moyasar SDK's card widget (which handles 3DS in-app when needed),
/// then persists the result via `POST /payments/:orderId/confirm` — the
/// backend independently re-verifies against Moyasar, so nothing here is
/// ever treated as final until that call succeeds. The order itself stays
/// `pending` throughout: card payments are authorize-only, the restaurant
/// still has to accept the order before money is captured.
class CardPaymentScreen extends ConsumerStatefulWidget {
  final Order order;

  const CardPaymentScreen({super.key, required this.order});

  @override
  ConsumerState<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

enum _Phase { loadingIntent, intentError, enteringCard, confirming, verificationFailed, confirmError, success }

class _CardPaymentScreenState extends ConsumerState<CardPaymentScreen> {
  _Phase _phase = _Phase.loadingIntent;
  PaymentIntent? _intent;
  String? _errorMessage;
  // Kept so a failed/erroring confirm can be retried with the exact same
  // provider payment id — confirm() is safe to call more than once, the
  // backend just re-verifies and no-ops if it was already applied.
  String? _pendingProviderPaymentId;
  // Bumped to force-remount the Moyasar CreditCard widget (clearing its
  // internal form state) when the user needs to re-enter their card.
  int _formAttempt = 0;
  // User's opt-in to tokenize this card — wired into CreditCardConfig.saveCard.
  // A SavedCard only ever gets created on the backend when a payment is made
  // with save_card true, so this toggle is the only thing that ever
  // populates the saved-cards list.
  bool _saveCard = false;
  // Which saved card is currently mid-charge (shows a spinner on that row);
  // null when none is in flight.
  String? _chargingCardId;

  @override
  void initState() {
    super.initState();
    _loadIntent();
  }

  Future<void> _loadIntent() async {
    setState(() => _phase = _Phase.loadingIntent);
    final repo = ref.read(paymentRepositoryProvider);
    final result = await repo.createIntent(widget.order.id);
    if (!mounted) return;
    result.fold(
      (failure) {
        setState(() {
          _phase = _Phase.intentError;
          _errorMessage = _messageFor(failure);
        });
      },
      (intent) {
        if (intent.providerData.publishableApiKey == null) {
          setState(() {
            _phase = _Phase.intentError;
            _errorMessage = 'checkout.card_payment_unavailable'.tr();
          });
          return;
        }
        setState(() {
          _intent = intent;
          _phase = _Phase.enteringCard;
        });
      },
    );
  }

  String _messageFor(Failure failure) {
    final code = (failure.cause is ApiException)
        ? (failure.cause as ApiException).code
        : null;
    switch (code) {
      case 'ORDER_NOT_FOUND':
        return 'checkout.card_payment_order_not_found'.tr();
      case 'PAYMENT_ALREADY_PROCESSED':
        return 'checkout.card_payment_already_processed'.tr();
      case 'PAYMENT_VERIFICATION_FAILED':
        return 'checkout.card_payment_verification_failed'.tr();
      case 'SAVED_CARD_NOT_FOUND':
        return 'checkout.card_payment_saved_card_not_found'.tr();
      case 'MOYASAR_API_ERROR':
      case 'MOYASAR_UNAVAILABLE':
        return 'checkout.card_payment_provider_unavailable'.tr();
      default:
        return 'checkout.card_payment_generic_error'.tr();
    }
  }

  Future<void> _confirm(String providerPaymentId) async {
    setState(() {
      _phase = _Phase.confirming;
      _pendingProviderPaymentId = providerPaymentId;
    });
    final repo = ref.read(paymentRepositoryProvider);
    final result = await repo.confirmPayment(
      orderId: widget.order.id,
      providerPaymentId: providerPaymentId,
    );
    if (!mounted) return;
    result.fold(
      (failure) {
        final code = (failure.cause is ApiException)
            ? (failure.cause as ApiException).code
            : null;
        setState(() {
          // A verification mismatch is never auto-retried — it means what
          // Moyasar actually charged doesn't match what we expected, which
          // should never normally happen and must never be silently
          // swallowed. The user can still request a manual retry below,
          // but this is surfaced as a real failure, not a transient hiccup.
          _phase = code == 'PAYMENT_VERIFICATION_FAILED'
              ? _Phase.verificationFailed
              : _Phase.confirmError;
          _errorMessage = _messageFor(failure);
        });
      },
      (payment) {
        if (payment.status == 'FAILED') {
          setState(() {
            _phase = _Phase.confirmError;
            _errorMessage = 'checkout.card_payment_declined'.tr();
          });
          return;
        }
        setState(() => _phase = _Phase.success);
      },
    );
  }

  /// Backend-initiated saved-card charge — no Moyasar SDK widget involved,
  /// just `POST /payments/:orderId/cards/:cardId/charge` with an optional
  /// {cvc}. On the rare `providerData.transactionUrl` response, a plain
  /// in-app WebView (not the SDK's) handles the 3DS challenge; either way,
  /// confirmation reuses [_confirm] with the SAME payment id this endpoint
  /// returned — by design, our backend makes that id equal Moyasar's
  /// payment id for this flow, so there's no separate id to hunt for.
  Future<void> _chargeSavedCard(SavedCard card, {String? cvc}) async {
    setState(() => _chargingCardId = card.id);
    final repo = ref.read(paymentRepositoryProvider);
    final result = await repo.chargeSavedCard(
      orderId: widget.order.id,
      cardId: card.id,
      cvc: cvc,
    );
    if (!mounted) return;
    setState(() => _chargingCardId = null);
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_messageFor(failure)),
            backgroundColor: KZ.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (charge) async {
        final transactionUrl = charge.providerData?.transactionUrl;
        if (transactionUrl == null || transactionUrl.isEmpty) {
          _confirm(charge.paymentId);
          return;
        }
        final callbackUrl = _intent?.providerData.callbackUrl;
        if (callbackUrl == null || callbackUrl.isEmpty) {
          // Nothing to detect completion against — surface this rather
          // than opening a WebView that can never know it's done.
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('checkout.card_payment_generic_error'.tr()),
              backgroundColor: KZ.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        final completed = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => SavedCard3dsScreen(
              transactionUrl: transactionUrl,
              callbackUrl: callbackUrl,
            ),
          ),
        );
        if (completed == true) {
          _confirm(charge.paymentId);
        }
        // Otherwise the user backed out of the challenge — nothing was
        // confirmed, the order stays exactly as it was.
      },
    );
  }

  void _openChargeSheet(SavedCard card) {
    final cvcController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: KZ.sp20),
                  decoration: BoxDecoration(
                    color: KZ.outlineVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              _WalletCard(brand: card.brand, lastFour: card.lastFour),
              const SizedBox(height: KZ.sp20),
              Text(
                'checkout.card_payment_pay_with_card'.tr(
                  namedArgs: {
                    'brand': card.brand,
                    'lastFour': card.lastFour,
                  },
                ),
                style: KZ.sectionTitle.copyWith(fontSize: 17),
              ),
              const SizedBox(height: KZ.sp16),
              TextField(
                controller: cvcController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: 'checkout.card_payment_cvc_optional'.tr(),
                  counterText: '',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  filled: true,
                  fillColor: KZ.surfaceContainerLow,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(KZ.radiusMd)),
                    borderSide: BorderSide(color: KZ.outlineVariant),
                  ),
                ),
              ),
              const SizedBox(height: KZ.sp16),
              KZButton(
                fullWidth: true,
                pill: true,
                label: 'checkout.card_payment_pay_amount'.tr(
                  namedArgs: {
                    'amount': formatCurrency(
                      widget.order.grandTotal,
                      locale: context.locale,
                    ),
                  },
                ),
                onPressed: () {
                  Navigator.pop(sheetContext);
                  final cvc = cvcController.text.trim();
                  _chargeSavedCard(card, cvc: cvc.isEmpty ? null : cvc);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Extracts a display message from any of the Moyasar SDK's error result
  /// types (they don't share a common base class, only a `.message` field).
  String _sdkErrorMessage(Object result) {
    try {
      final message = (result as dynamic).message;
      if (message is String && message.isNotEmpty) return message;
    } catch (_) {
      // Fall through to the generic message below.
    }
    return 'checkout.card_payment_generic_error'.tr();
  }

  void _onPaymentResult(dynamic result) {
    if (result is moyasar.PaymentResponse) {
      _confirm(result.id);
      return;
    }
    // Any SDK error object (ApiError, NetworkError, ValidationError,
    // PaymentCanceledError, TimeoutError, UnprocessableTokenError,
    // UnspecifiedError, AuthError) — no provider payment id exists yet, so
    // there is nothing to confirm; let the user re-enter their card.
    setState(() {
      _errorMessage = _sdkErrorMessage(result as Object);
      _formAttempt++;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_errorMessage!),
        backgroundColor: KZ.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KZ.surface,
      appBar: AppBar(
        backgroundColor: KZ.surface,
        elevation: 0,
        foregroundColor: KZ.primary,
        title: Text(
          'checkout.card_payment_title'.tr(),
          style: KZ.pageTitle.copyWith(color: KZ.primary),
        ),
      ),
      body: SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_phase) {
      case _Phase.loadingIntent:
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(KZ.primary),
          ),
        );
      case _Phase.intentError:
        return KZErrorState(
          message: _errorMessage ?? 'checkout.card_payment_generic_error'.tr(),
          retryLabel: 'common.retry'.tr(),
          onRetry: _loadIntent,
        );
      case _Phase.enteringCard:
        return _buildCardForm(context);
      case _Phase.confirming:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: KZ.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(KZ.primary),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: KZ.sp20),
                Text(
                  'checkout.card_payment_confirming'.tr(),
                  style: KZ.bodyLarge.copyWith(
                    color: KZ.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      case _Phase.verificationFailed:
      case _Phase.confirmError:
        return _buildConfirmFailure(context);
      case _Phase.success:
        return _buildSuccess(context);
    }
  }

  Widget _buildCardForm(BuildContext context) {
    final intent = _intent!;
    final providerData = intent.providerData;
    final config = moyasar.PaymentConfig(
      publishableApiKey: providerData.publishableApiKey!,
      amount: providerData.amount,
      currency: providerData.currency,
      description: providerData.description ??
          'checkout.card_payment_description'.tr(
            namedArgs: {'orderNumber': widget.order.orderNumber},
          ),
      // Hard requirement: the backend uses this to verify the payment it
      // receives at /confirm actually belongs to this order.
      metadata: {'orderId': providerData.orderId},
      creditCard: moyasar.CreditCardConfig(
        saveCard: _saveCard,
        // Authorize-only — matches the backend's manual-capture intent;
        // the restaurant must accept the order before anything is captured.
        manual: providerData.manual,
      ),
    );

    final authState = ref.watch(authNotifierProvider);
    final isGuest = !authState.isLoggedIn || (authState.user?.isGuest ?? true);
    final savedCardsState = isGuest ? null : ref.watch(savedCardsNotifierProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _AmountHeroCard(
          amount: formatCurrency(widget.order.grandTotal, locale: context.locale),
        ),
        if (savedCardsState != null && savedCardsState.cards.isNotEmpty) ...[
          const SizedBox(height: KZ.sp28),
          _SectionHeader(
            icon: Icons.wallet_rounded,
            label: 'checkout.card_payment_saved_cards'.tr(),
          ),
          const SizedBox(height: KZ.sp12),
          ...savedCardsState.cards.map(
            (card) => Padding(
              padding: const EdgeInsets.only(bottom: KZ.sp12),
              child: _SavedCardOption(
                card: card,
                isCharging: _chargingCardId == card.id,
                enabled: _chargingCardId == null,
                onTap: () => _openChargeSheet(card),
              ),
            ),
          ),
          const SizedBox(height: KZ.sp8),
          Row(
            children: [
              Expanded(child: Divider(color: KZ.outlineVariant.withValues(alpha: 0.6))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: KZ.sp10),
                child: Text(
                  'checkout.card_payment_or_new_card'.tr(),
                  style: KZ.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Expanded(child: Divider(color: KZ.outlineVariant.withValues(alpha: 0.6))),
            ],
          ),
          const SizedBox(height: KZ.sp8),
        ] else
          const SizedBox(height: KZ.sp28),
        _SectionHeader(
          icon: Icons.credit_card_rounded,
          label: 'checkout.card_payment_new_card_title'.tr(),
        ),
        const SizedBox(height: KZ.sp12),
        // No background/border/radius of our own here on purpose: the
        // Moyasar SDK already draws its own white, softly-shadowed boxes
        // around "Name on Card" and "Card Information" — wrapping those in
        // a second box (even a radius-matched one) reads as a frame inside
        // a frame. Padding only, so Moyasar's fields are the only boxes on
        // screen.
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: KeyedSubtree(
            key: ValueKey(_formAttempt),
            child: moyasar.CreditCard(
              config: config,
              onPaymentResult: _onPaymentResult,
              locale: context.locale.languageCode == 'ar'
                  ? const moyasar.Localization.ar()
                  : const moyasar.Localization.en(),
            ),
          ),
        ),
        if (!isGuest) ...[
          const SizedBox(height: KZ.sp12),
          _SaveCardToggle(
            value: _saveCard,
            onChanged: (v) => setState(() => _saveCard = v),
          ),
        ],
        const SizedBox(height: KZ.sp20),
        const _SecurityFootnote(),
      ],
    );
  }

  Widget _buildConfirmFailure(BuildContext context) {
    final isVerificationFailure = _phase == _Phase.verificationFailed;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: KZ.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, size: 56, color: KZ.error),
            ),
            const SizedBox(height: KZ.sp20),
            Text(
              _errorMessage ?? 'checkout.card_payment_generic_error'.tr(),
              textAlign: TextAlign.center,
              style: KZ.body.copyWith(color: KZ.onSurfaceVariant),
            ),
            if (isVerificationFailure) ...[
              const SizedBox(height: KZ.sp8),
              Text(
                'checkout.card_payment_verification_failed_notice'.tr(),
                textAlign: TextAlign.center,
                style: KZ.bodySmall.copyWith(color: KZ.error),
              ),
            ],
            const SizedBox(height: KZ.sp24),
            // Safe to retry: confirm() re-verifies against Moyasar and
            // no-ops if this payment was already applied — never a
            // duplicate charge from pressing this again.
            KZButton(
              fullWidth: true,
              label: 'checkout.card_payment_retry_confirm'.tr(),
              onPressed: _pendingProviderPaymentId != null
                  ? () => _confirm(_pendingProviderPaymentId!)
                  : null,
            ),
            const SizedBox(height: KZ.sp10),
            KZButton(
              fullWidth: true,
              variant: KZButtonVariant.tertiary,
              label: 'checkout.card_payment_enter_different_card'.tr(),
              onPressed: () {
                setState(() {
                  _phase = _Phase.enteringCard;
                  _formAttempt++;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: KZ.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                size: 64,
                color: KZ.primary,
              ),
            ),
            const SizedBox(height: KZ.sp20),
            // Honest state: the payment is authorized, not "confirmed" —
            // the restaurant still has to accept the order before the hold
            // is captured. Never claim the order itself is confirmed here.
            Text(
              'checkout.card_payment_awaiting_title'.tr(),
              style: KZ.display.copyWith(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: KZ.sp8),
            Text(
              'checkout.card_payment_awaiting_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: KZ.bodyLarge.copyWith(color: KZ.onSurfaceVariant),
            ),
            const SizedBox(height: KZ.sp32),
            KZButton(
              fullWidth: true,
              pill: true,
              label: 'checkout.card_payment_view_order'.tr(),
              onPressed: () {
                context.go('/orders/tracking/${widget.order.id}');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// One tappable saved-card row in the checkout picker — brand/last-four/
/// expiry only, same display rule as the Saved Cards management screen.
/// Styled as a compact "wallet card" so it reads as a real payment method,
/// not a generic list row.
class _SavedCardOption extends StatelessWidget {
  final SavedCard card;
  final bool isCharging;
  final bool enabled;
  final VoidCallback onTap;

  const _SavedCardOption({
    required this.card,
    required this.isCharging,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final expiry =
        '${card.expMonth.toString().padLeft(2, '0')}/${(card.expYear % 100).toString().padLeft(2, '0')}';
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(KZ.radiusLg),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(KZ.radiusLg),
        child: Ink(
          padding: const EdgeInsets.all(KZ.sp16),
          decoration: BoxDecoration(
            gradient: cardBrandGradient(card.brand),
            borderRadius: BorderRadius.circular(KZ.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.credit_card_rounded, color: Colors.white, size: 26),
              const SizedBox(width: KZ.sp12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'saved_cards.card_label'.tr(
                        namedArgs: {
                          'brand': card.brand,
                          'lastFour': card.lastFour,
                        },
                      ),
                      style: KZ.itemTitle.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'saved_cards.expires'.tr(namedArgs: {'expiry': expiry}),
                      style: KZ.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (isCharging)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small, non-interactive version of [_SavedCardOption]'s look — shown at
/// the top of the CVC bottom sheet so the user can see which card they're
/// about to pay with.
class _WalletCard extends StatelessWidget {
  final String brand;
  final String lastFour;

  const _WalletCard({required this.brand, required this.lastFour});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KZ.sp16),
      decoration: BoxDecoration(
        gradient: cardBrandGradient(brand),
        borderRadius: BorderRadius.circular(KZ.radiusLg),
      ),
      child: Row(
        children: [
          const Icon(Icons.credit_card_rounded, color: Colors.white, size: 24),
          const SizedBox(width: KZ.sp10),
          Text(
            'saved_cards.card_label'.tr(
              namedArgs: {'brand': brand, 'lastFour': lastFour},
            ),
            style: KZ.itemTitle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient hero showing the amount due — same visual language as the order
/// tracking screen's status banner, so this screen doesn't read as a bare
/// default form dropped into an otherwise branded app.
class _AmountHeroCard extends StatelessWidget {
  final String amount;

  const _AmountHeroCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [KZ.primary, KZ.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: KZ.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.lock_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'checkout.card_payment_amount_due'.tr(),
                  style: KZ.caption.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                ),
                const SizedBox(height: 2),
                Text(
                  amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KZ.display.copyWith(fontSize: 26, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Small icon + label section header, used consistently for both the
/// saved-cards and new-card sections of this screen.
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: KZ.primary, size: 20),
        const SizedBox(width: KZ.sp8),
        Text(
          label,
          style: KZ.sectionTitle.copyWith(fontSize: 16),
        ),
      ],
    );
  }
}

/// Replaces the default Material [Checkbox] row with a selectable card that
/// matches the checked/unchecked selection treatment used elsewhere in
/// checkout (e.g. loyalty reward rows) instead of looking like a bare
/// system control.
class _SaveCardToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SaveCardToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(KZ.radiusMd),
      child: Container(
        constraints: const BoxConstraints(minHeight: KZ.iconTapTargetMin),
        padding: const EdgeInsets.symmetric(horizontal: KZ.sp14, vertical: KZ.sp12),
        decoration: BoxDecoration(
          color: value
              ? KZ.primary.withValues(alpha: 0.06)
              : KZ.surfaceContainerLow,
          borderRadius: BorderRadius.circular(KZ.radiusMd),
          border: Border.all(
            color: value ? KZ.primary : KZ.outlineVariant,
            width: value ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              value ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: value ? KZ.primary : KZ.outlineVariant,
              size: KZ.iconControl,
            ),
            const SizedBox(width: KZ.sp10),
            Expanded(
              child: Text(
                'checkout.card_payment_save_card'.tr(),
                style: KZ.itemTitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small trust cue at the bottom of the card-entry form — reiterates the
/// real security model (never our own words to invent, just a plain
/// restatement of what's actually true: raw card data only ever goes to
/// Moyasar, never to our backend).
class _SecurityFootnote extends StatelessWidget {
  const _SecurityFootnote();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.verified_user_outlined, size: 16, color: KZ.onSurfaceVariant.withValues(alpha: 0.7)),
        const SizedBox(width: KZ.sp6),
        Flexible(
          child: Text(
            'checkout.card_payment_security_footnote'.tr(),
            textAlign: TextAlign.center,
            style: KZ.caption.copyWith(color: KZ.onSurfaceVariant.withValues(alpha: 0.7)),
          ),
        ),
      ],
    );
  }
}
