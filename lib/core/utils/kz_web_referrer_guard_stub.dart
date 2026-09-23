/// Non-web fallback — there is no browser `Referer` header to guard here.
void applyStrictNoReferrer() {}

/// Non-web fallback — nothing to restore.
void restoreDefaultReferrerPolicy() {}
