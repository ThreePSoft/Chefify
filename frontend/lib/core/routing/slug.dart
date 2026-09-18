String createSlug(String value) {
  final normalized = value.trim().toLowerCase();
  final slug = normalized
      .replaceAll(RegExp(r'[^\p{L}\p{M}\p{N}]+', unicode: true), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');

  if (slug.isNotEmpty) {
    return slug;
  }

  final codePoints = normalized.runes
      .where((codePoint) => String.fromCharCode(codePoint).trim().isNotEmpty)
      .map((codePoint) => codePoint.toRadixString(16))
      .join('-');
  return codePoints.isEmpty ? 'item' : 'item-$codePoints';
}
