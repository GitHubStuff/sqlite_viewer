
import 'package:persisted_cache/persisted_cache.dart';

class PersistedSingleton {
  static PersistedSingleton? _instance;
  static PersistedCubit _buildCubit = PersistedCubit();

  PersistedCubit get cubit => _buildCubit;

  PersistedSingleton._internal() {
    _instance = this;
    cubit;
  }

  factory PersistedSingleton() => _instance ?? PersistedSingleton._internal();
}
