extension IterableExtensions<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) selector) {
    final map = <K, List<E>>{};
    for (final element in this) {
      final key = selector(element);
      map.putIfAbsent(key, () => []).add(element);
    }
    return map;
  }
}
