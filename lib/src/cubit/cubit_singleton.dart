import 'build_cubit.dart';

class CubitSingleton {
  static CubitSingleton? _instance;
  static BuildCubit _buildCubit = BuildCubit();

  BuildCubit get cubit => _buildCubit;

  CubitSingleton._internal() {
    _instance = this;
    cubit;
  }

  factory CubitSingleton() => _instance ?? CubitSingleton._internal();
}
