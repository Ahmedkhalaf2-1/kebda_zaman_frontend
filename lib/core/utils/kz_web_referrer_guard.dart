/// Sets (and later restores) a strict `no-referrer` meta policy while the
/// password-reset page is visible, so the raw reset token embedded in this
/// page's URL is never leaked via the `Referer` header if the page ever
/// loads or links to an external resource.
///
/// Conditionally exported so mobile builds never pull in `dart:html` (which
/// does not exist there) — a no-op on every non-web platform, where this
/// specific URL-leak vector doesn't exist in the first place.
library;

export 'kz_web_referrer_guard_stub.dart'
    if (dart.library.html) 'kz_web_referrer_guard_web.dart';
