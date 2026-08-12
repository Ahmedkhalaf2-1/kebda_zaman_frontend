import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:kebda_zaman/core/theme/kz_design_system.dart';

/// In-app 3DS challenge for a saved-card charge (`POST
/// /payments/:orderId/cards/:cardId/charge`'s rare `providerData.
/// transactionUrl` case). This bypasses the Moyasar SDK entirely — the
/// charge itself was backend-initiated, so there is no SDK widget/session
/// to hand this off to; this is a plain WebView we drive ourselves.
///
/// Completion is detected by watching for a navigation back to our own
/// backend's callback host (the same `callbackUrl` returned by the payment
/// intent) — mirroring how the Moyasar SDK's own 3DS view detects
/// completion by matching the redirect host. If that heuristic doesn't
/// fire for some reason, a visible "I've completed this" fallback lets the
/// user unstick themselves rather than being trapped in the WebView.
///
/// Pops `true` once completion is detected (caller then calls
/// `POST /payments/:orderId/confirm` with the charge's payment id), or
/// `false`/nothing if the user backs out — in that case nothing has been
/// confirmed and the order stays exactly as it was.
class SavedCard3dsScreen extends StatefulWidget {
  final String transactionUrl;
  final String callbackUrl;

  const SavedCard3dsScreen({
    super.key,
    required this.transactionUrl,
    required this.callbackUrl,
  });

  @override
  State<SavedCard3dsScreen> createState() => _SavedCard3dsScreenState();
}

class _SavedCard3dsScreenState extends State<SavedCard3dsScreen> {
  late final WebViewController _controller;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    final callbackHost = Uri.tryParse(widget.callbackUrl)?.host;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (pageUrl) {
            if (_done || callbackHost == null) return;
            final reached = Uri.tryParse(pageUrl);
            if (reached != null && reached.host == callbackHost) {
              _finish();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.transactionUrl));
  }

  void _finish() {
    if (_done || !mounted) return;
    _done = true;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: KZ.surface,
        elevation: 0,
        foregroundColor: KZ.primary,
        title: Text(
          'checkout.card_payment_3ds_title'.tr(),
          style: KZ.pageTitle.copyWith(color: KZ.primary, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: _finish,
            child: Text(
              'checkout.card_payment_3ds_done'.tr(),
              style: KZ.labelLarge.copyWith(color: KZ.primary),
            ),
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
