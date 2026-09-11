/// Tri-state wrapper for the `comment` field on a review PATCH request.
///
/// A plain `String?` parameter can't distinguish "leave the comment alone"
/// from "clear the comment" — both would be `null`. Per
/// RATINGS_REVIEWS_API_CONTRACT.md, PATCH semantics are:
///   - key omitted entirely  -> comment unchanged
///   - `comment: null`       -> comment cleared
///   - `comment: ""` / whitespace -> comment cleared
///   - `comment: "text"`     -> comment trimmed + saved
///
/// Callers that don't want to touch the comment simply omit this parameter
/// (it defaults to [ReviewCommentPatch.absent]); callers that want to clear
/// it pass [ReviewCommentPatch.clear]; callers setting new text pass
/// [ReviewCommentPatch.value].
sealed class ReviewCommentPatch {
  const ReviewCommentPatch();

  static const ReviewCommentPatch absent = _Absent();
  static const ReviewCommentPatch clear = _Value(null);

  factory ReviewCommentPatch.value(String text) = _Value.text;
}

class _Absent extends ReviewCommentPatch {
  const _Absent();
}

class _Value extends ReviewCommentPatch {
  final String? text;
  const _Value(this.text);
  const _Value.text(String this.text);
}

/// Applies tri-state PATCH semantics to a mutable request body: omits the
/// `comment` key entirely when [patch] is absent, otherwise sends the
/// trimmed text (or `null` for a blank/whitespace-only value, matching the
/// backend's own clearing rule for an empty string).
extension ReviewCommentPatchX on ReviewCommentPatch {
  void applyTo(Map<String, dynamic> body) {
    switch (this) {
      case _Absent():
        return;
      case _Value(text: final text):
        final trimmed = text?.trim();
        body['comment'] = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    }
  }
}
