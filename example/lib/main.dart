import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'modular/app_module.dart';
import 'modular/theme_and_material_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Enable theme changes/monitoring by creating a 'hive' object to persist information

  /// Set BLoC observer for additional console messages

  BlocOverrides.runZoned(
    () => runApp(ModularApp(
      module: AppModule(),
      child: ThemeAndMaterialWidget(),
    )),
    blocObserver: null, //SimpleBlocObserver(),
    // NOTE: For release blocObserver: null,
  );
}
