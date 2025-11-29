abstract class LocalStorage<T> {
  void save({required String key, required T content});
  Future<T?> read({required String key});
}
