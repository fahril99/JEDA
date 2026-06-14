import 'dart:math';

class WeightedRandom {
  final _rand = Random();

  /// Picks an item by weight. Skips recently shown items if possible.
  T pickByWeight<T>(
    List<T> items,
    int Function(T) weightGetter, {
    List<String> recentIds = const [],
    String Function(T)? idGetter,
  }) {
    if (items.isEmpty) throw Exception('WeightedRandom: items list is empty');
    if (items.length == 1) return items.first;

    // Filter out recent if possible
    List<T> candidates = items;
    if (idGetter != null && recentIds.isNotEmpty) {
      final filtered = items.where((i) => !recentIds.contains(idGetter(i))).toList();
      if (filtered.isNotEmpty) candidates = filtered;
    }

    final totalWeight = candidates.fold(0, (sum, item) => sum + weightGetter(item));
    if (totalWeight <= 0) return candidates[_rand.nextInt(candidates.length)];

    int roll = _rand.nextInt(totalWeight);
    for (final item in candidates) {
      roll -= weightGetter(item);
      if (roll < 0) return item;
    }

    return candidates.last;
  }
}
