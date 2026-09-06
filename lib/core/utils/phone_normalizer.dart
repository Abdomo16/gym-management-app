/// Centralized phone normalization.
///
/// Equivalent representations of the same phone (`010 1234 5678`,
/// `010-1234-5678`, `+20 10 1234 5678`) are collapsed into a single stored
/// value so the database's unique constraint can detect real duplicates
/// without being fooled by formatting differences.
///
/// The normalization is deliberately conservative: only whitespace and
/// common formatting characters are removed, a leading `+` is preserved, and
/// no regional/national re-write is attempted.
abstract final class PhoneNormalizer {
  /// Normalizes [value] for storage and comparison.
  ///
  /// * trims surrounding whitespace
  /// * removes spaces, dashes, dots, parentheses and slashes
  /// * keeps a leading `+` (country code marker) if present
  ///
  /// Returns an empty string for empty input.
  static String normalize(String? value) {
    if (value == null) {
      return '';
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    final hasPlus = trimmed.startsWith('+');
    final digits = trimmed.replaceAll(RegExp(r'[^\d]'), '');
    return hasPlus ? '+$digits' : digits;
  }
}
