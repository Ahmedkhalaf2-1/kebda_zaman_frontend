// dart:html is deprecated in favor of package:web/dart:js_interop, and this
// file is deliberately a web-only conditional-export target (never compiled
// for mobile) — both lints are expected and intentional here.
// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

String? _previousContent;
bool _hadExistingTag = false;

/// Installs (or tightens) a `<meta name="referrer" content="no-referrer">`
/// tag for as long as the reset-password page is visible. Remembers
/// whatever policy was there before so [restoreDefaultReferrerPolicy] can
/// put it back rather than leaving `no-referrer` active app-wide after the
/// user navigates away.
void applyStrictNoReferrer() {
  final existing = html.document.head?.querySelector('meta[name="referrer"]');
  if (existing != null) {
    _hadExistingTag = true;
    _previousContent = existing.getAttribute('content');
    existing.setAttribute('content', 'no-referrer');
    return;
  }
  _hadExistingTag = false;
  _previousContent = null;
  final meta = html.MetaElement()
    ..name = 'referrer'
    ..content = 'no-referrer';
  html.document.head?.append(meta);
}

/// Restores whatever referrer policy (or absence of one) was in place
/// before [applyStrictNoReferrer] ran.
void restoreDefaultReferrerPolicy() {
  final existing = html.document.head?.querySelector('meta[name="referrer"]');
  if (existing == null) return;
  if (_hadExistingTag) {
    if (_previousContent != null) {
      existing.setAttribute('content', _previousContent!);
    }
  } else {
    existing.remove();
  }
}
